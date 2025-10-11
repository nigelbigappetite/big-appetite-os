-- =====================================================
-- SIGNALS SCHEMA - Input from the World
-- =====================================================
-- This schema captures all external signals that feed into the system.
-- Each signal type has its own table with common fields plus type-specific data.
-- All signals are processed to extract actor information and behavioral insights.

-- =====================================================
-- SIGNALS BASE TABLE
-- =====================================================
-- Common fields for all signal types
CREATE TABLE signals.signals_base (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    signal_type TEXT NOT NULL,
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id) ON DELETE CASCADE,
    
    -- Raw and processed content
    raw_content TEXT NOT NULL,
    processed_content JSONB,
    
    -- Actor identification (may be null for unknown actors)
    actor_id UUID, -- Will reference actors.actors when that schema is created
    actor_identifier TEXT, -- Phone, email, handle, etc.
    actor_identifier_type TEXT, -- 'phone', 'email', 'social_handle', etc.
    
    -- Processing metadata
    received_at TIMESTAMPTZ NOT NULL,
    processed_at TIMESTAMPTZ,
    processing_status TEXT DEFAULT 'pending',
    confidence_in_matching FLOAT DEFAULT 0.0, -- 0-1 confidence in actor matching
    
    -- Source and context
    source_platform TEXT NOT NULL,
    source_id TEXT, -- External ID from the platform
    source_metadata JSONB DEFAULT '{}',
    
    -- Signal-specific metadata
    metadata JSONB DEFAULT '{}',
    
    -- Quality and validation
    quality_score FLOAT DEFAULT 0.0, -- 0-1 signal quality
    is_duplicate BOOLEAN DEFAULT false,
    duplicate_of UUID REFERENCES signals.signals_base(signal_id),
    
    -- Constraints
    CONSTRAINT valid_signal_type CHECK (signal_type IN (
        'whatsapp_message', 'review', 'social_comment', 'order', 
        'web_behavior', 'email_interaction', 'survey_response', 'crm_event'
    )),
    CONSTRAINT valid_processing_status CHECK (processing_status IN (
        'pending', 'processing', 'completed', 'failed', 'skipped'
    )),
    CONSTRAINT valid_confidence CHECK (confidence_in_matching >= 0 AND confidence_in_matching <= 1),
    CONSTRAINT valid_quality_score CHECK (quality_score >= 0 AND quality_score <= 1)
);

-- =====================================================
-- WHATSAPP MESSAGES TABLE
-- =====================================================
CREATE TABLE signals.whatsapp_messages (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Message details
    message_text TEXT NOT NULL,
    message_type TEXT NOT NULL DEFAULT 'text',
    media_url TEXT,
    media_type TEXT,
    
    -- Conversation context
    conversation_id TEXT,
    is_inbound BOOLEAN NOT NULL,
    reply_to_message_id TEXT,
    
    -- Sender information
    sender_phone TEXT NOT NULL,
    sender_name TEXT,
    sender_profile_pic_url TEXT,
    
    -- Message metadata
    whatsapp_message_id TEXT UNIQUE,
    timestamp TIMESTAMPTZ NOT NULL,
    
    -- Processing results
    sentiment_score FLOAT, -- -1 to 1
    intent_classification JSONB,
    entities_extracted JSONB,
    
    -- Constraints
    CONSTRAINT valid_message_type CHECK (message_type IN ('text', 'image', 'audio', 'video', 'document', 'location', 'contact')),
    CONSTRAINT valid_media_type CHECK (media_type IN ('image/jpeg', 'image/png', 'audio/mpeg', 'video/mp4', 'application/pdf', 'text/plain') OR media_type IS NULL),
    CONSTRAINT valid_sentiment CHECK (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1))
);

-- =====================================================
-- REVIEWS TABLE
-- =====================================================
CREATE TABLE signals.reviews (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Review content
    review_text TEXT NOT NULL,
    rating INTEGER NOT NULL,
    title TEXT,
    
    -- Review platform
    platform TEXT NOT NULL, -- 'google', 'yelp', 'facebook', 'tripadvisor', etc.
    platform_review_id TEXT,
    platform_url TEXT,
    
    -- Reviewer information
    reviewer_name TEXT,
    reviewer_photo_url TEXT,
    is_verified_purchase BOOLEAN DEFAULT false,
    
    -- Review metadata
    review_date TIMESTAMPTZ NOT NULL,
    helpful_votes INTEGER DEFAULT 0,
    total_votes INTEGER DEFAULT 0,
    
    -- Business response
    business_response TEXT,
    business_response_date TIMESTAMPTZ,
    
    -- Processing results
    sentiment_score FLOAT, -- -1 to 1
    topics_mentioned JSONB, -- Array of topics extracted
    keywords JSONB, -- Important keywords
    
    -- Constraints
    CONSTRAINT valid_rating CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT valid_platform CHECK (platform IN ('google', 'yelp', 'facebook', 'tripadvisor', 'opentable', 'zomato', 'other')),
    CONSTRAINT valid_sentiment CHECK (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1))
);

-- =====================================================
-- SOCIAL COMMENTS TABLE
-- =====================================================
CREATE TABLE signals.social_comments (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Comment content
    comment_text TEXT NOT NULL,
    comment_type TEXT NOT NULL DEFAULT 'comment',
    
    -- Social platform
    platform TEXT NOT NULL, -- 'instagram', 'facebook', 'twitter', 'tiktok', etc.
    platform_post_id TEXT,
    platform_comment_id TEXT UNIQUE,
    platform_url TEXT,
    
    -- Commenter information
    commenter_username TEXT,
    commenter_display_name TEXT,
    commenter_photo_url TEXT,
    commenter_followers_count INTEGER,
    is_verified BOOLEAN DEFAULT false,
    
    -- Engagement metrics
    likes_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    
    -- Comment metadata
    comment_date TIMESTAMPTZ NOT NULL,
    is_reply BOOLEAN DEFAULT false,
    parent_comment_id TEXT,
    
    -- Processing results
    sentiment_score FLOAT, -- -1 to 1
    hashtags JSONB, -- Array of hashtags
    mentions JSONB, -- Array of @mentions
    topics_mentioned JSONB, -- Array of topics
    
    -- Constraints
    CONSTRAINT valid_platform CHECK (platform IN ('instagram', 'facebook', 'twitter', 'tiktok', 'youtube', 'linkedin', 'other')),
    CONSTRAINT valid_comment_type CHECK (comment_type IN ('comment', 'reply', 'mention', 'share')),
    CONSTRAINT valid_sentiment CHECK (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1))
);

-- =====================================================
-- ORDER HISTORY TABLE
-- =====================================================
CREATE TABLE signals.order_history (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Order details
    order_number TEXT NOT NULL,
    order_date TIMESTAMPTZ NOT NULL,
    order_status TEXT NOT NULL,
    
    -- Customer information
    customer_phone TEXT,
    customer_email TEXT,
    customer_name TEXT,
    delivery_address JSONB, -- Full address object
    
    -- Order items
    items JSONB NOT NULL, -- Array of items with details
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    tip_amount DECIMAL(10,2) DEFAULT 0,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Order method and timing
    order_method TEXT NOT NULL, -- 'online', 'phone', 'in_store', 'app'
    payment_method TEXT NOT NULL,
    delivery_method TEXT NOT NULL, -- 'delivery', 'pickup', 'dine_in'
    
    -- Timing information
    order_time TIMESTAMPTZ,
    estimated_ready_time TIMESTAMPTZ,
    actual_ready_time TIMESTAMPTZ,
    delivery_time TIMESTAMPTZ,
    
    -- Special instructions
    special_instructions TEXT,
    dietary_restrictions JSONB, -- Array of restrictions
    
    -- Processing results
    order_patterns JSONB, -- Recurring patterns detected
    customer_preferences JSONB, -- Inferred preferences
    satisfaction_indicators JSONB, -- Signs of satisfaction/dissatisfaction
    
    -- Constraints
    CONSTRAINT valid_order_status CHECK (order_status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT valid_order_method CHECK (order_method IN ('online', 'phone', 'in_store', 'app', 'third_party')),
    CONSTRAINT valid_payment_method CHECK (payment_method IN ('cash', 'card', 'digital_wallet', 'online_payment', 'other')),
    CONSTRAINT valid_delivery_method CHECK (delivery_method IN ('delivery', 'pickup', 'dine_in', 'drive_through')),
    CONSTRAINT valid_amounts CHECK (subtotal >= 0 AND tax_amount >= 0 AND tip_amount >= 0 AND delivery_fee >= 0 AND total_amount >= 0)
);

-- =====================================================
-- WEB BEHAVIOR TABLE
-- =====================================================
CREATE TABLE signals.web_behavior (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Session information
    session_id TEXT NOT NULL,
    user_agent TEXT,
    ip_address INET,
    
    -- Page and action details
    page_url TEXT NOT NULL,
    page_title TEXT,
    action_type TEXT NOT NULL, -- 'page_view', 'click', 'scroll', 'form_submit', etc.
    element_id TEXT,
    element_text TEXT,
    
    -- Navigation context
    referrer_url TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    utm_term TEXT,
    utm_content TEXT,
    
    -- Timing information
    timestamp TIMESTAMPTZ NOT NULL,
    time_on_page INTEGER, -- Seconds
    scroll_depth FLOAT, -- 0-1 percentage
    
    -- Device and browser
    device_type TEXT, -- 'desktop', 'mobile', 'tablet'
    browser TEXT,
    operating_system TEXT,
    screen_resolution TEXT,
    
    -- Conversion tracking
    conversion_goal TEXT,
    conversion_value DECIMAL(10,2),
    funnel_step TEXT,
    
    -- Processing results
    behavior_patterns JSONB, -- Detected patterns
    intent_signals JSONB, -- Purchase intent indicators
    engagement_score FLOAT, -- 0-1 engagement level
    
    -- Constraints
    CONSTRAINT valid_action_type CHECK (action_type IN ('page_view', 'click', 'scroll', 'form_submit', 'download', 'video_play', 'exit')),
    CONSTRAINT valid_device_type CHECK (device_type IN ('desktop', 'mobile', 'tablet', 'other')),
    CONSTRAINT valid_scroll_depth CHECK (scroll_depth IS NULL OR (scroll_depth >= 0 AND scroll_depth <= 1)),
    CONSTRAINT valid_engagement_score CHECK (engagement_score IS NULL OR (engagement_score >= 0 AND engagement_score <= 1))
);

-- =====================================================
-- EMAIL INTERACTIONS TABLE
-- =====================================================
CREATE TABLE signals.email_interactions (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Email details
    email_subject TEXT NOT NULL,
    email_content TEXT NOT NULL,
    email_type TEXT NOT NULL, -- 'sent', 'received', 'bounced', 'opened', 'clicked'
    
    -- Sender/Recipient
    sender_email TEXT NOT NULL,
    recipient_email TEXT NOT NULL,
    sender_name TEXT,
    recipient_name TEXT,
    
    -- Email metadata
    email_id TEXT UNIQUE,
    message_id TEXT, -- RFC 2822 Message-ID
    thread_id TEXT,
    
    -- Campaign information
    campaign_id TEXT,
    campaign_name TEXT,
    template_id TEXT,
    
    -- Interaction details
    interaction_timestamp TIMESTAMPTZ NOT NULL,
    link_clicked TEXT,
    attachment_downloaded TEXT,
    
    -- Email platform
    platform TEXT NOT NULL, -- 'sendgrid', 'mailchimp', 'constant_contact', etc.
    platform_event_id TEXT,
    
    -- Processing results
    sentiment_score FLOAT, -- -1 to 1
    topics_mentioned JSONB,
    call_to_action_clicked TEXT,
    unsubscribe_requested BOOLEAN DEFAULT false,
    
    -- Constraints
    CONSTRAINT valid_email_type CHECK (email_type IN ('sent', 'received', 'bounced', 'opened', 'clicked', 'unsubscribed', 'complained')),
    CONSTRAINT valid_platform CHECK (platform IN ('sendgrid', 'mailchimp', 'constant_contact', 'hubspot', 'active_campaign', 'other')),
    CONSTRAINT valid_sentiment CHECK (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1))
);

-- =====================================================
-- SURVEY RESPONSES TABLE
-- =====================================================
CREATE TABLE signals.survey_responses (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Survey details
    survey_id TEXT NOT NULL,
    survey_name TEXT,
    question_id TEXT NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL,
    
    -- Response details
    response_text TEXT,
    response_value TEXT, -- For multiple choice, rating scales
    response_numeric FLOAT, -- For numeric responses
    response_boolean BOOLEAN, -- For yes/no questions
    
    -- Survey context
    survey_version TEXT,
    survey_channel TEXT, -- 'email', 'sms', 'web', 'in_person'
    completion_percentage FLOAT, -- 0-1
    
    -- Respondent information
    respondent_id TEXT,
    respondent_email TEXT,
    respondent_phone TEXT,
    
    -- Timing
    response_timestamp TIMESTAMPTZ NOT NULL,
    time_to_complete INTEGER, -- Seconds
    
    -- Processing results
    response_sentiment FLOAT, -- -1 to 1
    response_confidence FLOAT, -- 0-1 confidence in response quality
    topics_mentioned JSONB,
    
    -- Constraints
    CONSTRAINT valid_question_type CHECK (question_type IN ('text', 'multiple_choice', 'rating_scale', 'yes_no', 'numeric', 'date', 'email', 'phone')),
    CONSTRAINT valid_survey_channel CHECK (survey_channel IN ('email', 'sms', 'web', 'in_person', 'phone', 'other')),
    CONSTRAINT valid_completion_percentage CHECK (completion_percentage >= 0 AND completion_percentage <= 1),
    CONSTRAINT valid_sentiment CHECK (response_sentiment IS NULL OR (response_sentiment >= -1 AND response_sentiment <= 1)),
    CONSTRAINT valid_confidence CHECK (response_confidence IS NULL OR (response_confidence >= 0 AND response_confidence <= 1))
);

-- =====================================================
-- CRM EVENTS TABLE
-- =====================================================
CREATE TABLE signals.crm_events (
    signal_id UUID PRIMARY KEY REFERENCES signals.signals_base(signal_id) ON DELETE CASCADE,
    
    -- Event details
    event_type TEXT NOT NULL,
    event_name TEXT NOT NULL,
    event_description TEXT,
    
    -- CRM system
    crm_system TEXT NOT NULL, -- 'salesforce', 'hubspot', 'pipedrive', etc.
    crm_record_id TEXT,
    crm_object_type TEXT, -- 'contact', 'lead', 'opportunity', 'deal', etc.
    
    -- Event context
    event_timestamp TIMESTAMPTZ NOT NULL,
    event_source TEXT, -- 'api', 'webhook', 'import', 'manual'
    
    -- Related entities
    related_contact_id TEXT,
    related_company_id TEXT,
    related_deal_id TEXT,
    
    -- Event data
    event_data JSONB NOT NULL, -- Flexible event-specific data
    event_metadata JSONB DEFAULT '{}',
    
    -- Processing results
    event_importance FLOAT, -- 0-1 importance score
    event_sentiment FLOAT, -- -1 to 1
    patterns_detected JSONB,
    
    -- Constraints
    CONSTRAINT valid_event_type CHECK (event_type IN ('created', 'updated', 'deleted', 'status_changed', 'assigned', 'unassigned', 'converted', 'merged')),
    CONSTRAINT valid_crm_system CHECK (crm_system IN ('salesforce', 'hubspot', 'pipedrive', 'zoho', 'monday', 'other')),
    CONSTRAINT valid_crm_object_type CHECK (crm_object_type IN ('contact', 'lead', 'opportunity', 'deal', 'account', 'company', 'task', 'note', 'other')),
    CONSTRAINT valid_event_source CHECK (event_source IN ('api', 'webhook', 'import', 'manual', 'integration')),
    CONSTRAINT valid_importance CHECK (event_importance IS NULL OR (event_importance >= 0 AND event_importance <= 1)),
    CONSTRAINT valid_sentiment CHECK (event_sentiment IS NULL OR (event_sentiment >= -1 AND event_sentiment <= 1))
);

-- =====================================================
-- INDEXES FOR SIGNALS SCHEMA
-- =====================================================

-- Base signals indexes
CREATE INDEX IF NOT EXISTS idx_signals_base_brand_id ON signals.signals_base(brand_id);
CREATE INDEX IF NOT EXISTS idx_signals_base_signal_type ON signals.signals_base(signal_type);
CREATE INDEX IF NOT EXISTS idx_signals_base_actor_id ON signals.signals_base(actor_id) WHERE actor_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_signals_base_actor_identifier ON signals.signals_base(actor_identifier) WHERE actor_identifier IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_signals_base_received_at ON signals.signals_base(received_at);
CREATE INDEX IF NOT EXISTS idx_signals_base_processing_status ON signals.signals_base(processing_status);
CREATE INDEX IF NOT EXISTS idx_signals_base_duplicate_of ON signals.signals_base(duplicate_of) WHERE duplicate_of IS NOT NULL;

-- WhatsApp messages indexes
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_sender_phone ON signals.whatsapp_messages(sender_phone);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_conversation_id ON signals.whatsapp_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON signals.whatsapp_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_is_inbound ON signals.whatsapp_messages(is_inbound);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_reviews_platform ON signals.reviews(platform);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON signals.reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_review_date ON signals.reviews(review_date);
CREATE INDEX IF NOT EXISTS idx_reviews_platform_review_id ON signals.reviews(platform_review_id);

-- Social comments indexes
CREATE INDEX IF NOT EXISTS idx_social_comments_platform ON signals.social_comments(platform);
CREATE INDEX IF NOT EXISTS idx_social_comments_commenter_username ON signals.social_comments(commenter_username);
CREATE INDEX IF NOT EXISTS idx_social_comments_comment_date ON signals.social_comments(comment_date);
CREATE INDEX IF NOT EXISTS idx_social_comments_platform_comment_id ON signals.social_comments(platform_comment_id);

-- Order history indexes
CREATE INDEX IF NOT EXISTS idx_order_history_order_number ON signals.order_history(order_number);
CREATE INDEX IF NOT EXISTS idx_order_history_customer_phone ON signals.order_history(customer_phone) WHERE customer_phone IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_order_history_customer_email ON signals.order_history(customer_email) WHERE customer_email IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_order_history_order_date ON signals.order_history(order_date);
CREATE INDEX IF NOT EXISTS idx_order_history_order_status ON signals.order_history(order_status);

-- Web behavior indexes
CREATE INDEX IF NOT EXISTS idx_web_behavior_session_id ON signals.web_behavior(session_id);
CREATE INDEX IF NOT EXISTS idx_web_behavior_page_url ON signals.web_behavior(page_url);
CREATE INDEX IF NOT EXISTS idx_web_behavior_timestamp ON signals.web_behavior(timestamp);
CREATE INDEX IF NOT EXISTS idx_web_behavior_action_type ON signals.web_behavior(action_type);

-- Email interactions indexes
CREATE INDEX IF NOT EXISTS idx_email_interactions_sender_email ON signals.email_interactions(sender_email);
CREATE INDEX IF NOT EXISTS idx_email_interactions_recipient_email ON signals.email_interactions(recipient_email);
CREATE INDEX IF NOT EXISTS idx_email_interactions_campaign_id ON signals.email_interactions(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_email_interactions_interaction_timestamp ON signals.email_interactions(interaction_timestamp);

-- Survey responses indexes
CREATE INDEX IF NOT EXISTS idx_survey_responses_survey_id ON signals.survey_responses(survey_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_respondent_email ON signals.survey_responses(respondent_email) WHERE respondent_email IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_survey_responses_respondent_phone ON signals.survey_responses(respondent_phone) WHERE respondent_phone IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_survey_responses_response_timestamp ON signals.survey_responses(response_timestamp);

-- CRM events indexes
CREATE INDEX IF NOT EXISTS idx_crm_events_crm_system ON signals.crm_events(crm_system);
CREATE INDEX IF NOT EXISTS idx_crm_events_event_type ON signals.crm_events(event_type);
CREATE INDEX IF NOT EXISTS idx_crm_events_crm_record_id ON signals.crm_events(crm_record_id);
CREATE INDEX IF NOT EXISTS idx_crm_events_event_timestamp ON signals.crm_events(event_timestamp);
CREATE INDEX IF NOT EXISTS idx_crm_events_related_contact_id ON signals.crm_events(related_contact_id) WHERE related_contact_id IS NOT NULL;

-- =====================================================
-- COMMENTS FOR SIGNALS SCHEMA
-- =====================================================

COMMENT ON SCHEMA signals IS 'Input signals from the world - all external data that feeds into the system';
COMMENT ON TABLE signals.signals_base IS 'Common fields for all signal types with actor matching and processing metadata';
COMMENT ON TABLE signals.whatsapp_messages IS 'WhatsApp conversations and messages with sentiment and intent analysis';
COMMENT ON TABLE signals.reviews IS 'Customer reviews from various platforms with sentiment and topic extraction';
COMMENT ON TABLE signals.social_comments IS 'Social media comments and interactions with engagement metrics';
COMMENT ON TABLE signals.order_history IS 'Customer order history with behavioral pattern detection';
COMMENT ON TABLE signals.web_behavior IS 'Website user behavior tracking with conversion funnel analysis';
COMMENT ON TABLE signals.email_interactions IS 'Email marketing interactions and campaign performance';
COMMENT ON TABLE signals.survey_responses IS 'Survey and feedback responses with sentiment analysis';
COMMENT ON TABLE signals.crm_events IS 'CRM system events and data changes for customer journey tracking';

COMMENT ON COLUMN signals.signals_base.confidence_in_matching IS 'Confidence score (0-1) in matching this signal to an actor';
COMMENT ON COLUMN signals.signals_base.quality_score IS 'Signal quality score (0-1) based on completeness and reliability';
COMMENT ON COLUMN signals.signals_base.is_duplicate IS 'Whether this signal is a duplicate of another';
COMMENT ON COLUMN signals.whatsapp_messages.sentiment_score IS 'Sentiment analysis result (-1 to 1)';
COMMENT ON COLUMN signals.whatsapp_messages.intent_classification IS 'Detected intent categories and confidence scores';
COMMENT ON COLUMN signals.reviews.topics_mentioned IS 'Extracted topics and their relevance scores';
COMMENT ON COLUMN signals.social_comments.hashtags IS 'Array of hashtags found in the comment';
COMMENT ON COLUMN signals.order_history.items IS 'Order items with quantities, prices, and modifications';
COMMENT ON COLUMN signals.web_behavior.behavior_patterns IS 'Detected behavioral patterns and anomalies';
COMMENT ON COLUMN signals.email_interactions.call_to_action_clicked IS 'Which CTA was clicked in the email';
COMMENT ON COLUMN signals.survey_responses.response_confidence IS 'Confidence in response quality and authenticity';
COMMENT ON COLUMN signals.crm_events.event_importance IS 'Calculated importance score (0-1) for the event';
