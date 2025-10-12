import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

async function checkTables() {
  console.log('🔍 Checking what tables exist...');
  
  try {
    // Try to query information_schema to see what tables exist
    const { data, error } = await supabase
      .rpc('get_tables_info');
    
    if (error) {
      console.log('❌ RPC failed, trying direct query...');
      
      // Try to query the brands table directly
      const { data: brands, error: brandError } = await supabase
        .from('brands')
        .select('*')
        .limit(1);
      
      if (brandError) {
        console.log('❌ Direct brands query failed:', brandError.message);
      } else {
        console.log('✅ Found brands table in public schema');
        console.log('✅ Brands count:', brands?.length || 0);
      }
    } else {
      console.log('✅ Tables found:', data);
    }
  } catch (err) {
    console.log('❌ Error:', err.message);
  }
}

checkTables().catch(console.error);
