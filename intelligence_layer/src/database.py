import os
from supabase import create_client, Client
from .config import SUPABASE_URL, SUPABASE_KEY

class DatabaseManager:
    def __init__(self):
        """Initialize Supabase client"""
        self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    def get_driver_ontology(self):
        """Get driver ontology from database"""
        try:
            result = self.supabase.rpc('get_drivers').execute()
            if result.data:
                return result.data
            return []
        except Exception as e:
            print(f"Error getting driver ontology: {e}")
            return []
    
    def get_driver_conflicts(self):
        """Get driver conflicts from database"""
        try:
            result = self.supabase.rpc('get_driver_conflicts').execute()
            if result.data:
                return result.data
            return []
        except Exception as e:
            print(f"Error getting driver conflicts: {e}")
            return []
    
    def get_actor_profile(self, actor_id):
        """Get actor profile from database"""
        try:
            result = self.supabase.table('actor_profiles').select('*').eq('actor_id', actor_id).execute()
            if result.data:
                return result.data[0]
            return None
        except Exception as e:
            print(f"Error getting actor profile: {e}")
            return None
    
    def update_actor_profile(self, actor_id, profile_data):
        """Update actor profile in database"""
        try:
            result = self.supabase.table('actor_profiles').upsert({
                'actor_id': actor_id,
                **profile_data
            }).execute()
            return result.data
        except Exception as e:
            print(f"Error updating actor profile: {e}")
            return None
    
    def get_actor_history(self, actor_id):
        """Get actor history from database"""
        try:
            result = self.supabase.table('actor_updates').select('*').eq('actor_id', actor_id).order('created_at', desc=True).limit(10).execute()
            if result.data:
                return result.data
            return []
        except Exception as e:
            print(f"Error getting actor history: {e}")
            return []
    
    def get_signal_data(self, signal_id):
        """Get signal data preferring unified view, fallback to raw tables."""
        try:
            # 1) Try unified view
            try:
                uni = self.supabase.table('signals_unified').select('*').eq('signal_id', signal_id).limit(1).execute()
                if uni.data:
                    row = uni.data[0]
                    return {
                        **row,
                        'signal_text': row.get('signal_text') or row.get('raw_content') or '',
                        'signal_type': row.get('signal_type') or 'unknown',
                        'source_platform': row.get('source_platform') or 'unknown'
                    }
            except Exception:
                pass

            # 2) Fallback to raw tables with correct columns
            raw_sources = [
                ('whatsapp_messages', 'message_text', 'whatsapp'),
                ('reviews', 'review_text', 'review'),
                ('survey_responses', 'response_text', 'survey'),
                ('signals', 'raw_content', 'signal')
            ]
            for table, text_col, typ in raw_sources:
                try:
                    res = self.supabase.table(table).select('*').eq('signal_id', signal_id).limit(1).execute()
                    if res.data:
                        sd = res.data[0]
                        sd['signal_text'] = sd.get(text_col) or sd.get('raw_content', '')
                        sd['signal_type'] = typ
                        sd['source_platform'] = sd.get('source_platform', table)
                        return sd
                except Exception:
                    continue
            return None
        except Exception as e:
            print(f"Error getting signal data: {e}")
            return None
    
    def get_cost_summary(self):
        """Get cost summary from API usage table"""
        try:
            result = self.supabase.table('api_usage').select('*').execute()
            if result.data:
                total_cost = sum(record.get('cost', 0) for record in result.data)
                total_tokens = sum(record.get('total_tokens', 0) for record in result.data)
                return {
                    'total_cost': total_cost,
                    'total_tokens': total_tokens,
                    'record_count': len(result.data)
                }
            return {'total_cost': 0, 'total_tokens': 0, 'record_count': 0}
        except Exception as e:
            print(f"Error getting cost summary: {e}")
            return {'total_cost': 0, 'total_tokens': 0, 'record_count': 0}
    
    def log_decoder_output(self, decoder_data):
        """Log decoder output to database (don't expect a returned id)"""
        try:
            self.supabase.table('decoder_log').insert(decoder_data).execute()
            return True
        except Exception as e:
            print(f"Error logging decoder output: {e}")
            return False
    
    def log_api_usage(self, usage_data):
        """Log API usage for cost tracking (don't expect a returned id)"""
        try:
            self.supabase.table('api_usage').insert(usage_data).execute()
            return True
        except Exception as e:
            print(f"Error logging API usage: {e}")
            return False

    def create_actor_profile(self, brand_id=None, identifiers=None):
        """Create minimal actor; Postgres generates actor_id via DEFAULT."""
        try:
            data = {'brand_id': brand_id, 'identifiers': identifiers or {}}
            res = self.supabase.table('actor_profiles').insert(data).execute()
            if res.data:
                return res.data[0].get('actor_id')
        except Exception:
            pass
        return None

    def attach_actor_id_to_signal(self, signal_id, signal_type, actor_id):
        """Write actor_id back to source table for future linking."""
        table = 'whatsapp_messages' if signal_type == 'whatsapp' else (
            'reviews' if signal_type == 'review' else (
                'survey_responses' if signal_type == 'survey' else 'signals'
            )
        )
        try:
            self.supabase.table(table).update({'actor_id': actor_id}).eq('signal_id', signal_id).execute()
            return True
        except Exception:
            return False

    def find_actor_by_identifiers(self, brand_id=None, identifiers=None):
        """Try to find an existing actor by brand_id + identifier matches (priority ordered)."""
        if not identifiers:
            return None
        keys_priority = ['email', 'sender_phone', 'respondent_id', 'reviewer_name', 'source_id']
        for key in keys_priority:
            val = identifiers.get(key)
            if not val:
                continue
            try:
                # JSONB path filter: identifiers->>key = val
                result = (
                    self.supabase
                    .table('actor_profiles')
                    .select('actor_id, identifiers, brand_id')
                    .eq('brand_id', brand_id) if brand_id else self.supabase.table('actor_profiles').select('actor_id, identifiers, brand_id')
                )
                # supabase-py cannot chain conditional easily; rebuild
            except Exception:
                result = None
            try:
                query = self.supabase.table('actor_profiles').select('actor_id, identifiers, brand_id')
                if brand_id:
                    query = query.eq('brand_id', brand_id)
                query = query.filter(f"identifiers->>{key}", 'eq', str(val))
                res = query.limit(1).execute()
                if res.data:
                    return res.data[0].get('actor_id')
            except Exception:
                continue
        return None

    def upsert_actor_identifiers(self, actor_id, new_identifiers):
        """Merge new identifiers into actor_profiles.identifiers."""
        if not new_identifiers:
            return True
        try:
            # Fetch current identifiers
            cur = self.supabase.table('actor_profiles').select('identifiers').eq('actor_id', actor_id).limit(1).execute()
            current = cur.data[0]['identifiers'] if cur.data else {}
            merged = {**(current or {}), **new_identifiers}
            self.supabase.table('actor_profiles').update({'identifiers': merged}).eq('actor_id', actor_id).execute()
            return True
        except Exception:
            return False

    def update_actor_profile_quantum(self, actor_id, signal_analysis, signal_id=None, signal_type='unknown', signal_context=None):
        """Call DB Bayesian+quantum updater. Returns DB result or None."""
        try:
            payload = {
                'p_actor_id': actor_id,
                'signal_analysis': signal_analysis,
                'signal_id': signal_id,
                'signal_type': signal_type,
                'signal_context': signal_context or {}
            }
            # Call the function in actors schema - use direct SQL since RPC doesn't work with schema prefixes
            sql = """
            SELECT actors.update_actor_profile_quantum(
                %(p_actor_id)s::uuid,
                %(signal_analysis)s::jsonb,
                %(signal_id)s::uuid,
                %(signal_type)s::text,
                %(signal_context)s::jsonb
            )
            """
            res = self.supabase.rpc('exec_sql', {
                'sql': sql,
                'params': [
                    str(actor_id),
                    signal_analysis,
                    str(signal_id) if signal_id else None,
                    signal_type,
                    signal_context or {}
                ]
            }).execute()
            return res.data[0] if getattr(res, 'data', None) else None
        except Exception as e:
            print(f"Error calling update_actor_profile_quantum: {e}")
            return None

    def get_unprocessed_signals(self, limit=10):
        """Fetch unprocessed signals from unified view (or raw tables if view missing)."""
        try:
            # Prefer unified view with processing state
            try:
                # Left join to exclude already processed
                query = """
                SELECT s.*
                FROM signals_unified s
                LEFT JOIN signal_processing_state p ON s.signal_id = p.signal_id
                WHERE p.processed_at IS NULL
                ORDER BY s.source_timestamp DESC NULLS LAST
                LIMIT %s
                """
                result = self.supabase.rpc('exec_sql', {'sql': query, 'params': [limit]}).execute()
                if result.data:
                    return result.data
            except Exception:
                pass

            # Fallback: read from raw tables (no state tracking) - INBOUND ONLY
            raw_sources = [
                ('whatsapp_messages', 'message_text', 'whatsapp', 'message_direction'),
                ('reviews', 'review_text', 'review', None),
                ('signals', 'raw_content', 'signal', None)
            ]
            out = []
            for table, text_col, typ, direction_col in raw_sources:
                try:
                    query = self.supabase.table(table).select('*')
                    # Filter WhatsApp to inbound only
                    if typ == 'whatsapp' and direction_col:
                        query = query.in_(direction_col, ['inbound', 'received'])
                    res = query.order('created_at', desc=True).limit(limit).execute()
                    if res.data:
                        for row in res.data:
                            row['signal_text'] = row.get(text_col) or row.get('raw_content', '')
                            row['signal_type'] = typ
                            row['source_platform'] = row.get('source_platform', table)
                        out.extend(res.data)
                except Exception:
                    continue
            return out[:limit]
        except Exception as e:
            print(f"Error fetching unprocessed signals: {e}")
            return []

    def mark_signal_processed(self, signal_id, status='processed', error_message=None):
        """Mark a signal as processed (or error) in processing state."""
        try:
            data = {
                'signal_id': signal_id,
                'status': status,
                'processed_at': 'now()',
                'error_message': error_message
            }
            result = self.supabase.table('signal_processing_state').upsert(data).execute()
            return result.data
        except Exception as e:
            print(f"Error marking signal processed: {e}")
            return None

# Create standalone functions for backward compatibility
def get_driver_ontology():
    db = DatabaseManager()
    return db.get_driver_ontology()

def get_driver_conflicts():
    db = DatabaseManager()
    return db.get_driver_conflicts()

def get_actor_profile(actor_id):
    db = DatabaseManager()
    return db.get_actor_profile(actor_id)

def update_actor_profile(actor_id, profile_data):
    db = DatabaseManager()
    return db.update_actor_profile(actor_id, profile_data)

def get_actor_history(actor_id):
    db = DatabaseManager()
    return db.get_actor_history(actor_id)

def get_signal_data(signal_id):
    db = DatabaseManager()
    return db.get_signal_data(signal_id)

def get_cost_summary():
    db = DatabaseManager()
    return db.get_cost_summary()

def log_decoder_output(decoder_data):
    db = DatabaseManager()
    return db.log_decoder_output(decoder_data)

def log_api_usage(usage_data):
    db = DatabaseManager()
    return db.log_api_usage(usage_data)

def get_unprocessed_signals(limit=10):
    db = DatabaseManager()
    return db.get_unprocessed_signals(limit)

def mark_signal_processed(signal_id, status='processed', error_message=None):
    db = DatabaseManager()
    return db.mark_signal_processed(signal_id, status, error_message)

def create_actor_profile(brand_id=None, identifiers=None):
    db = DatabaseManager()
    return db.create_actor_profile(brand_id, identifiers)

def attach_actor_id_to_signal(signal_id, signal_type, actor_id):
    db = DatabaseManager()
    return db.attach_actor_id_to_signal(signal_id, signal_type, actor_id)

def find_actor_by_identifiers(brand_id=None, identifiers=None):
    db = DatabaseManager()
    return db.find_actor_by_identifiers(brand_id, identifiers)

def upsert_actor_identifiers(actor_id, new_identifiers):
    db = DatabaseManager()
    return db.upsert_actor_identifiers(actor_id, new_identifiers)

def update_actor_profile_quantum(actor_id, signal_analysis, signal_id=None, signal_type='unknown', signal_context=None):
    db = DatabaseManager()
    return db.update_actor_profile_quantum(actor_id, signal_analysis, signal_id, signal_type, signal_context)
