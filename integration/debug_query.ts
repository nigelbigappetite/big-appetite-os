/**
 * Debug query to see what's happening
 */
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

async function debugQuery() {
  const options = {
    minAge: 1 * 60 * 60 * 1000, // 1 hour
    maxAge: 72 * 60 * 60 * 1000  // 72 hours
  };
  
  const minTime = new Date(Date.now() - options.maxAge).toISOString();
  const maxTime = new Date(Date.now() - options.minAge).toISOString();
  
  console.log('Debug Query Parameters:');
  console.log(`  Min age: ${options.minAge / (60 * 60 * 1000)} hours`);
  console.log(`  Max age: ${options.maxAge / (60 * 60 * 1000)} hours`);
  console.log(`  Min time: ${minTime}`);
  console.log(`  Max time: ${maxTime}`);
  console.log();
  
  // Get all posts
  const { data: allPosts } = await supabase
    .from('social_posts')
    .select('id, created_at, processed_by_agents, caption')
    .order('created_at', { ascending: false });
  
  console.log('All posts in database:');
  allPosts?.forEach((post, i) => {
    const age = Date.now() - new Date(post.created_at).getTime();
    const ageHours = Math.floor(age / (1000 * 60 * 60));
    const ageMinutes = Math.floor((age % (1000 * 60 * 60)) / (1000 * 60));
    
    const minTimeObj = new Date(minTime);
    const maxTimeObj = new Date(maxTime);
    const createdTimeObj = new Date(post.created_at);
    
    const inRange = createdTimeObj >= minTimeObj && createdTimeObj <= maxTimeObj;
    const isUnprocessed = post.processed_by_agents === false || post.processed_by_agents === null;
    
    console.log(`\n${i + 1}. Post: ${post.id}`);
    console.log(`   Caption: ${post.caption?.substring(0, 40)}...`);
    console.log(`   Created: ${post.created_at}`);
    console.log(`   Age: ${ageHours}h ${ageMinutes}m`);
    console.log(`   In time range: ${inRange ? '✅' : '❌'}`);
    console.log(`   Unprocessed: ${isUnprocessed ? '✅' : '❌'}`);
    console.log(`   Would be selected: ${(inRange && isUnprocessed) ? '✅ YES' : '❌ NO'}`);
  });
  
  // Now try the actual query
  const { data: queryResults, error } = await supabase
    .from('social_posts')
    .select('id')
    .gte('created_at', minTime)
    .lte('created_at', maxTime)
    .or('processed_by_agents.is.null,processed_by_agents.eq.false')
    .limit(10);
  
  console.log(`\n\nQuery results:`, queryResults);
  console.log(`Query error:`, error);
}

debugQuery().catch(console.error);
