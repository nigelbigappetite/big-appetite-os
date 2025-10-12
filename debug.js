import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function debug() {
  console.log('🔍 Debugging Supabase Connection...');
  
  // Check brands
  try {
    const { data: brands, error: brandError } = await supabase
      .from('core.brands')
      .select('*');
    
    if (brandError) {
      console.log('❌ Brand error:', brandError.message);
    } else {
      console.log('✅ Brands found:', brands?.length || 0);
      if (brands) brands.forEach(b => console.log('  -', b.brand_slug, b.brand_name));
    }
  } catch (err) {
    console.log('❌ Brand query failed:', err.message);
  }
  
  // Check CSV file
  try {
    const csvPath = 'data/sample_whatsapp_messages.csv';
    if (fs.existsSync(csvPath)) {
      const content = fs.readFileSync(csvPath, 'utf8');
      const lines = content.trim().split('\n');
      console.log('✅ CSV file found:', csvPath);
      console.log('✅ CSV lines:', lines.length);
      console.log('✅ First line:', lines[0]);
    } else {
      console.log('❌ CSV file not found:', csvPath);
    }
  } catch (err) {
    console.log('❌ CSV read failed:', err.message);
  }
  
  // Check environment
  console.log('✅ SUPABASE_URL:', process.env.SUPABASE_URL ? 'Set' : 'Not set');
  console.log('✅ SUPABASE_KEY:', process.env.SUPABASE_SERVICE_ROLE_KEY ? 'Set' : 'Not set');
}

debug().catch(console.error);
