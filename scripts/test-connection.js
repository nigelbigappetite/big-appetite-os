#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js';
import chalk from 'chalk';
import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

// Configuration
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

async function testConnection() {
    console.log(chalk.blue('🔍 Testing Supabase Connection'));
    console.log(chalk.blue('=============================\n'));
    
    if (!SUPABASE_KEY) {
        console.log(chalk.red('❌ No Supabase key found'));
        console.log(chalk.yellow('Please set SUPABASE_SERVICE_ROLE_KEY or SUPABASE_ANON_KEY in your environment'));
        process.exit(1);
    }
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
    
    try {
        // Test connection by querying brands table
        console.log('Testing database connection...');
        const { data: brands, error } = await supabase
            .from('core.brands')
            .select('brand_id, brand_name, brand_slug')
            .limit(5);
        
        if (error) {
            throw new Error(error.message);
        }
        
        console.log(chalk.green('✅ Database connection successful!'));
        console.log(chalk.green('✅ Brands table accessible'));
        
        if (brands && brands.length > 0) {
            console.log('\nAvailable brands:');
            brands.forEach(brand => {
                console.log(`  - ${brand.brand_slug} (${brand.brand_name})`);
            });
        } else {
            console.log(chalk.yellow('⚠️  No brands found in database'));
            console.log(chalk.yellow('You may need to run the seed data first'));
        }
        
        // Test signals table
        console.log('\nTesting signals tables...');
        const { error: signalsError } = await supabase
            .from('signals.whatsapp_messages')
            .select('signal_id')
            .limit(1);
        
        if (signalsError) {
            throw new Error(`Signals table error: ${signalsError.message}`);
        }
        
        console.log(chalk.green('✅ WhatsApp messages table accessible'));
        
        const { error: centralSignalsError } = await supabase
            .from('signals.signals')
            .select('signal_id')
            .limit(1);
        
        if (centralSignalsError) {
            throw new Error(`Central signals table error: ${centralSignalsError.message}`);
        }
        
        console.log(chalk.green('✅ Central signals table accessible'));
        
        console.log(chalk.green('\n🎉 All tests passed! Ready to ingest CSV data.'));
        
    } catch (error) {
        console.log(chalk.red('❌ Connection failed:'));
        console.log(chalk.red(error.message));
        process.exit(1);
    }
}

testConnection();
