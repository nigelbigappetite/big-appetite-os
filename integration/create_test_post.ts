/**
 * Create a new test post for processing
 */
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

async function createTestPost() {
  console.log('📝 Creating new test post...\n');
  
  const testPost = {
    id: `test_post_${Date.now()}`,
    brand_id: 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
    ghl_location_id: 'GSEYlcxpbSqmFNOQcL0s',
    caption: 'New test post for full pipeline testing! #wingshack #quantum',
    platform: 'instagram',
    post_id: `instagram_${Date.now()}`,
    status: 'published',
    published_at: new Date().toISOString(),
    raw_payload: { test: true, createdBy: 'integration-test' },
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  };
  
  const { data, error } = await supabase
    .from('social_posts')
    .insert(testPost)
    .select();
  
  if (error) {
    console.error('❌ Failed to create test post:', error);
    return;
  }
  
  console.log('✅ Test post created successfully!');
  console.log(`   ID: ${data[0].id}`);
  console.log(`   Caption: ${data[0].caption}`);
  console.log(`   Created: ${data[0].created_at}`);
  console.log('\n🔄 Now run: ./node_modules/.bin/tsx integration/quantum-agent-scheduler.ts trigger');
}

createTestPost().catch(console.error);
