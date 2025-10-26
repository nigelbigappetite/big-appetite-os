/**
 * Check for posts in database regardless of age
 */
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

async function checkAllPosts() {
  console.log('🔍 Checking for posts in database...\n');
  
  // Check total count
  const { count: totalCount } = await supabase
    .from('social_posts')
    .select('*', { count: 'exact', head: true });
  
  console.log(`📊 Total posts in database: ${totalCount || 0}\n`);
  
  if (totalCount === 0) {
    console.log('❌ No posts found in database.');
    console.log('\n💡 This means:');
    console.log('   1. GHL webhooks haven\'t sent any posts yet');
    console.log('   2. Or posts are being stored in a different table');
    console.log('\n🔧 Next steps:');
    console.log('   1. Check if your webhook server is running');
    console.log('   2. Verify GHL webhook is configured');
    console.log('   3. Check if posts exist in other tables');
    return;
  }
  
  // Get recent posts
  const { data: posts, error } = await supabase
    .from('social_posts')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(10);
  
  if (error) {
    console.error('❌ Error fetching posts:', error);
    return;
  }
  
  console.log(`📝 Recent posts (last 10):\n`);
  
  posts?.forEach((post, index) => {
    const age = new Date(Date.now() - new Date(post.created_at).getTime());
    const ageHours = Math.floor(age.getTime() / (1000 * 60 * 60));
    const ageMinutes = Math.floor((age.getTime() % (1000 * 60 * 60)) / (1000 * 60));
    
    console.log(`${index + 1}. Post ID: ${post.id}`);
    console.log(`   Caption: ${post.caption?.substring(0, 50) || '(no caption)'}...`);
    console.log(`   Platform: ${post.platform}`);
    console.log(`   Age: ${ageHours}h ${ageMinutes}m old`);
    console.log(`   Processed: ${post.processed_by_agents ? '✅' : '⏳'}`);
    console.log();
  });
  
  // Count by processing status
  const { count: processedCount } = await supabase
    .from('social_posts')
    .select('*', { count: 'exact', head: true })
    .eq('processed_by_agents', true);
  
  const { count: unprocessedCount } = await supabase
    .from('social_posts')
    .select('*', { count: 'exact', head: true })
    .or('processed_by_agents.is.null,processed_by_agents.eq.false');
  
  console.log(`\n📈 Processing Status:`);
  console.log(`   ✅ Processed: ${processedCount || 0}`);
  console.log(`   ⏳ Unprocessed: ${unprocessedCount || 0}`);
  
  // Check what would be eligible for processing with different age criteria
  console.log(`\n🎯 Eligibility with current settings (24-72 hours old):`);
  
  const minTime = new Date(Date.now() - 72 * 60 * 60 * 1000).toISOString();
  const maxTime = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  
  const { count: eligibleCount } = await supabase
    .from('social_posts')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', minTime)
    .lte('created_at', maxTime)
    .or('processed_by_agents.is.null,processed_by_agents.eq.false');
  
  console.log(`   Currently eligible: ${eligibleCount || 0}`);
  
  // Check older posts
  const olderTime = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const { count: olderCount } = await supabase
    .from('social_posts')
    .select('*', { count: 'exact', head: true })
    .lt('created_at', olderTime)
    .or('processed_by_agents.is.null,processed_by_agents.eq.false');
  
  console.log(`   Older than 24h (unprocessed): ${olderCount || 0}`);
  
  // Check newer posts
  const { count: newerCount } = await supabase
    .from('social_posts')
    .select('*', { count: 'exact', head: true })
    .gt('created_at', olderTime);
  
  console.log(`   Newer than 24h: ${newerCount || 0}`);
  
  console.log('\n💡 Tip: Posts need to be 24+ hours old to be processed.');
  console.log('   You can manually process any post with: npm run quantum:process <post-id>');
}

checkAllPosts().catch(console.error);
