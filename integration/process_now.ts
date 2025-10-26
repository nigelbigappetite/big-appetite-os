/**
 * Process post immediately
 */
import { processPost } from './agent-integration-service.js';

const postId = process.argv[2] || 'test_final_1761505491';

console.log(`🔄 Processing post: ${postId}...\n`);

const result = await processPost(postId);

console.log('\n✅ Processing complete!');
console.log(`   Success: ${result.success}`);
console.log(`   Duration: ${result.duration}ms`);
if (result.errors.length > 0) {
  console.log(`   Errors: ${result.errors.join(', ')}`);
}
if (result.generatedContent) {
  console.log(`   Content ID: ${result.generatedContent.copyId}`);
  if (result.generatedContent.assetId) {
    console.log(`   Asset ID: ${result.generatedContent.assetId}`);
  }
}
