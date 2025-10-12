-- Create survey_responses table in signals schema
-- This table stores individual survey responses for analysis

CREATE TABLE IF NOT EXISTS signals.survey_responses (
    signal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES core.brands(brand_id),
    survey_type TEXT NOT NULL,
    question TEXT NOT NULL,
    response TEXT NOT NULL,
    satisfaction_score INTEGER,
    respondent_id TEXT NOT NULL,
    survey_timestamp TIMESTAMP WITH TIME ZONE,
    raw_content TEXT NOT NULL,
    raw_metadata JSONB DEFAULT '{}'::jsonb,
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    intake_method TEXT,
    intake_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_survey_responses_brand_id ON signals.survey_responses(brand_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_survey_type ON signals.survey_responses(survey_type);
CREATE INDEX IF NOT EXISTS idx_survey_responses_respondent_id ON signals.survey_responses(respondent_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_satisfaction_score ON signals.survey_responses(satisfaction_score);
CREATE INDEX IF NOT EXISTS idx_survey_responses_survey_timestamp ON signals.survey_responses(survey_timestamp);

-- Add comments for documentation
COMMENT ON TABLE signals.survey_responses IS 'Individual survey responses for customer insights and behavioral analysis';
COMMENT ON COLUMN signals.survey_responses.signal_id IS 'Unique identifier for each survey response';
COMMENT ON COLUMN signals.survey_responses.brand_id IS 'Reference to the brand this response belongs to';
COMMENT ON COLUMN signals.survey_responses.survey_type IS 'Categorized type of survey question (demographics, behavior, preferences, etc.)';
COMMENT ON COLUMN signals.survey_responses.question IS 'The original survey question text';
COMMENT ON COLUMN signals.survey_responses.response IS 'The customer response to the question';
COMMENT ON COLUMN signals.survey_responses.satisfaction_score IS 'Numeric rating if applicable (1-5 or 1-10 scale)';
COMMENT ON COLUMN signals.survey_responses.respondent_id IS 'Customer identifier (email, phone, etc.)';
COMMENT ON COLUMN signals.survey_responses.survey_timestamp IS 'When the survey was completed';
COMMENT ON COLUMN signals.survey_responses.raw_content IS 'Complete survey response data as JSON';
COMMENT ON COLUMN signals.survey_responses.raw_metadata IS 'Additional metadata about the survey response';
COMMENT ON COLUMN signals.survey_responses.intake_method IS 'How this data was ingested (survey_intake, api, etc.)';
COMMENT ON COLUMN signals.survey_responses.intake_metadata IS 'Metadata about the data ingestion process';
