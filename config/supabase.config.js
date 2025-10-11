// Supabase Configuration
export const supabaseConfig = {
    url: process.env.SUPABASE_URL || 'https://phjawqphehkzfaezhzzf.supabase.co',
    anonKey: process.env.SUPABASE_ANON_KEY,
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
};

// Validate configuration
export function validateConfig() {
    if (!supabaseConfig.url) {
        throw new Error('SUPABASE_URL is required');
    }
    
    if (!supabaseConfig.anonKey && !supabaseConfig.serviceRoleKey) {
        throw new Error('Either SUPABASE_ANON_KEY or SUPABASE_SERVICE_ROLE_KEY is required');
    }
    
    return true;
}
