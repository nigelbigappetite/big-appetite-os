import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

const { data } = await supabase
  .from('social_posts')
  .select('*')
  .order('created_at', { ascending: false })
  .limit(5);

console.log('Recent posts:');
data?.forEach((p, i) => {
  console.log(`${i+1}. ${p.id}`);
  console.log(`   ${p.caption?.substring(0, 50)}`);
  console.log(`   Processed: ${p.processed_by_agents}`);
  console.log('');
});
