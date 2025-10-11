#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import ora from 'ora';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
const CSV_FILE = process.env.CSV_FILE || path.join(__dirname, '..', 'data', 'whatsapp_messages.csv');
const LOG_FILE = path.join(__dirname, '..', 'logs', 'ingestion.log');

// Ensure logs directory exists
const logsDir = path.dirname(LOG_FILE);
if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
}

// Initialize Supabase client
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// Logging function
function log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${type.toUpperCase()}: ${message}\n`;
    
    // Write to log file
    fs.appendFileSync(LOG_FILE, logMessage);
    
    // Also show in console
    if (type === 'error') {
        console.log(chalk.red(message));
    } else if (type === 'success') {
        console.log(chalk.green(message));
    } else {
        console.log(message);
    }
}

// Validate CSV file exists and is readable
function validateCSVFile(filePath) {
    if (!fs.existsSync(filePath)) {
        log(`CSV file not found: ${filePath}`, 'error');
        log('Please place your CSV file in the data/ folder as whatsapp_messages.csv', 'error');
        process.exit(1);
    }
    
    try {
        const stats = fs.statSync(filePath);
        if (stats.size === 0) {
            log('CSV file is empty', 'error');
            process.exit(1);
        }
        return true;
    } catch (error) {
        log(`Cannot read CSV file: ${error.message}`, 'error');
        process.exit(1);
    }
}

// Parse CSV file
function parseCSV(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.trim().split('\n');
    
    // Get headers
    const headers = lines[0].split(',').map(h => h.trim());
    const expectedHeaders = ['timestamp', 'sender', 'message', 'phone_number', 'brand', 'direction', 'conversation_id'];
    
    // Validate headers
    const missingHeaders = expectedHeaders.filter(h => !headers.includes(h));
    if (missingHeaders.length > 0) {
        log(`Missing required headers: ${missingHeaders.join(', ')}`, 'error');
        log(`Expected headers: ${expectedHeaders.join(', ')}`, 'error');
        process.exit(1);
    }
    
    // Parse data rows
    const rows = [];
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        
        const values = line.split(',').map(v => v.trim());
        if (values.length !== expectedHeaders.length) {
            log(`Row ${i + 1} has incorrect number of columns. Skipping.`, 'error');
            continue;
        }
        
        const row = {};
        expectedHeaders.forEach((header, index) => {
            row[header] = values[index];
        });
        rows.push(row);
    }
    
    return rows;
}

// Clean data
function cleanData(row) {
    // Clean phone number - add + prefix
    if (row.phone_number && !row.phone_number.startsWith('+')) {
        row.phone_number = '+' + row.phone_number;
    }
    
    // Clean sender name - remove ~ prefix
    if (row.sender && row.sender.startsWith('~')) {
        row.sender = row.sender.substring(1);
    }
    
    return row;
}

// Check if message is system message
function isSystemMessage(row) {
    const systemMessages = [
        'Messages and calls are end-to-end encrypted',
        'This message was deleted',
        'You deleted this message',
        'This message was deleted by the group admin',
        'You left',
        'You were added',
        'You joined using this group\'s invite link'
    ];
    
    const message = row.message.toLowerCase();
    return systemMessages.some(sysMsg => message.includes(sysMsg.toLowerCase())) || !row.message.trim();
}

// Get brand ID from brand name
async function getBrandId(brandName) {
    try {
        const { data, error } = await supabase
            .from('core.brands')
            .select('brand_id')
            .eq('brand_slug', brandName)
            .single();
        
        if (error) {
            log(`Brand '${brandName}' not found in database`, 'error');
            log('Available brands:', 'error');
            
            // Show available brands
            const { data: brands } = await supabase
                .from('core.brands')
                .select('brand_slug, brand_name');
            
            if (brands) {
                brands.forEach(brand => {
                    log(`  - ${brand.brand_slug} (${brand.brand_name})`, 'error');
                });
            }
            
            process.exit(1);
        }
        
        return data.brand_id;
    } catch (error) {
        log(`Error looking up brand: ${error.message}`, 'error');
        process.exit(1);
    }
}

// Check if message already exists (duplicate detection)
async function isDuplicate(row, brandId) {
    try {
        const { data, error } = await supabase
            .from('signals.whatsapp_messages')
            .select('signal_id')
            .eq('brand_id', brandId)
            .eq('sender_phone', row.phone_number)
            .eq('message_text', row.message)
            .eq('received_at', new Date(row.timestamp).toISOString())
            .limit(1);
        
        if (error) {
            log(`Error checking for duplicates: ${error.message}`, 'error');
            return false;
        }
        
        return data && data.length > 0;
    } catch (error) {
        log(`Error checking for duplicates: ${error.message}`, 'error');
        return false;
    }
}

// Insert message into database
async function insertMessage(row, brandId) {
    try {
        // Insert into whatsapp_messages table
        const { data: whatsappData, error: whatsappError } = await supabase
            .from('signals.whatsapp_messages')
            .insert({
                brand_id: brandId,
                sender_phone: row.phone_number,
                message_text: row.message,
                message_direction: row.direction,
                message_timestamp: new Date(row.timestamp).toISOString(),
                raw_content: JSON.stringify(row),
                raw_metadata: {
                    conversation_id: row.conversation_id,
                    sender: row.sender,
                    source: 'csv_upload'
                },
                received_at: new Date().toISOString(),
                processing_status: 'processed',
                intake_method: 'csv_upload',
                intake_metadata: {
                    uploaded_at: new Date().toISOString(),
                    conversation_id: row.conversation_id
                }
            })
            .select()
            .single();
        
        if (whatsappError) {
            throw new Error(`WhatsApp insert error: ${whatsappError.message}`);
        }
        
        // Insert into central signals table
        const { error: signalsError } = await supabase
            .from('signals.signals')
            .insert({
                brand_id: brandId,
                signal_type: 'whatsapp_message',
                source_platform: 'whatsapp',
                source_id: whatsappData.signal_id,
                raw_content: JSON.stringify(row),
                raw_metadata: {
                    conversation_id: row.conversation_id,
                    sender: row.sender,
                    whatsapp_signal_id: whatsappData.signal_id
                },
                source_timestamp: new Date(row.timestamp).toISOString(),
                received_at: new Date().toISOString(),
                intake_method: 'csv_upload',
                intake_metadata: {
                    uploaded_at: new Date().toISOString(),
                    conversation_id: row.conversation_id
                },
                quality_score: 1.0,
                is_duplicate: false
            });
        
        if (signalsError) {
            log(`Warning: Could not insert into signals table: ${signalsError.message}`, 'error');
        }
        
        return whatsappData.signal_id;
    } catch (error) {
        throw new Error(`Database insert error: ${error.message}`);
    }
}

// Main processing function
async function processCSV() {
    console.log(chalk.blue('🚀 WhatsApp CSV Ingestion Tool'));
    console.log(chalk.blue('================================\n'));
    
    // Validate CSV file
    log(`Reading CSV: ${CSV_FILE}`);
    validateCSVFile(CSV_FILE);
    
    // Parse CSV
    const rows = parseCSV(CSV_FILE);
    log(`Found ${rows.length} messages`);
    
    if (rows.length === 0) {
        log('No messages to process', 'error');
        process.exit(1);
    }
    
    // Get brand ID from first row
    const firstRow = rows[0];
    const brandId = await getBrandId(firstRow.brand);
    log(`Using brand ID: ${brandId}`);
    
    // Process messages
    const spinner = ora('Processing messages...').start();
    
    let processed = 0;
    let skipped = 0;
    let duplicates = 0;
    let systemMessages = 0;
    let errors = 0;
    
    for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        
        try {
            // Clean data
            const cleanedRow = cleanData(row);
            
            // Check if system message
            if (isSystemMessage(cleanedRow)) {
                systemMessages++;
                continue;
            }
            
            // Check for duplicates
            if (await isDuplicate(cleanedRow, brandId)) {
                duplicates++;
                continue;
            }
            
            // Insert message
            await insertMessage(cleanedRow, brandId);
            processed++;
            
            // Update spinner
            spinner.text = `Processing... ${i + 1}/${rows.length} (${processed} inserted, ${skipped} skipped)`;
            
        } catch (error) {
            errors++;
            log(`Error processing row ${i + 1}: ${error.message}`, 'error');
            continue;
        }
    }
    
    spinner.stop();
    
    // Show summary
    console.log('\n' + chalk.green('✅ Processing Complete!'));
    console.log(chalk.green('========================'));
    console.log(`Total rows in CSV: ${rows.length}`);
    console.log(`Messages inserted: ${chalk.green(processed)}`);
    console.log(`System messages skipped: ${chalk.yellow(systemMessages)}`);
    console.log(`Duplicates skipped: ${chalk.yellow(duplicates)}`);
    console.log(`Errors: ${errors > 0 ? chalk.red(errors) : chalk.green(0)}`);
    
    if (errors > 0) {
        console.log(chalk.red(`\nCheck logs for details: ${LOG_FILE}`));
    }
    
    log(`Processing complete. Inserted: ${processed}, Skipped: ${systemMessages + duplicates}, Errors: ${errors}`, 'success');
}

// Run the script
if (import.meta.url === `file://${process.argv[1]}`) {
    processCSV().catch(error => {
        log(`Fatal error: ${error.message}`, 'error');
        process.exit(1);
    });
}

export { processCSV };
