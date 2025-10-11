# Big Appetite OS - Database Schema Documentation

## Overview

Big Appetite OS implements a self-aware, learning business operating system through 8 interconnected schemas that work together to create a closed-loop learning system. Each schema serves a specific purpose in the signal → understanding → pattern → action → outcome → learning cycle.

## Schema Architecture

### 1. CORE Schema - Global Configuration

**Purpose**: Multi-tenant foundation with brand isolation, user management, and system configuration.

**Key Tables**:
- `brands` - Central tenant isolation, every piece of data belongs to a brand
- `users` - Brand-scoped user management with role-based access
- `brand_settings` - Flexible configuration storage per brand
- `system_parameters` - Global system configuration affecting all brands
- `brand_integrations` - External service connections and credentials
- `audit_log` - System-wide audit trail for compliance and debugging

**Design Principles**:
- Multi-tenancy through brand_id foreign keys
- Flexible configuration using JSONB
- Complete audit trails for compliance
- Role-based access control

### 2. SIGNALS Schema - Input from the World

**Purpose**: Capture all external signals that feed into the system for processing and actor matching.

**Key Tables**:
- `signals_base` - Common fields for all signal types with actor matching
- `whatsapp_messages` - WhatsApp conversations with sentiment analysis
- `reviews` - Customer reviews from various platforms
- `social_comments` - Social media interactions and engagement
- `order_history` - Customer order history with behavioral patterns
- `web_behavior` - Website user behavior tracking
- `email_interactions` - Email marketing interactions
- `survey_responses` - Survey and feedback responses
- `crm_events` - CRM system events and data changes

**Design Principles**:
- Common base table with type-specific extensions
- Confidence scoring for actor matching
- Quality scoring for signal reliability
- Duplicate detection and handling
- Full traceability to source systems

### 3. ACTORS Schema - Understanding of People

**Purpose**: Bayesian actor profiles where every attribute has uncertainty modeling and confidence tracking.

**Key Tables**:
- `actors` - Central actor registry with basic identification
- `actor_demographics` - Bayesian demographic beliefs with confidence scores
- `actor_identity_beliefs` - Stated vs. behavioral identity with alignment scoring
- `actor_behavioral_scores` - Context-dependent behavioral patterns
- `actor_communication_profiles` - Communication preferences and response patterns
- `actor_psychological_triggers` - Motivational triggers and behavioral impact
- `actor_preferences` - Stated vs. actual preferences with contradiction detection
- `actor_memory_loops` - Recurring behavioral patterns and habits
- `actor_friction_points` - Experience friction points and their impact
- `actor_contradictions` - Explicit tracking of belief-behavior contradictions
- `actor_belief_vectors` - Numeric vector representations for clustering
- `actor_clustering_metadata` - Metadata about actor clustering assignments

**Design Principles**:
- Every belief has confidence (0-1), not certainty
- Evidence count tracking for each belief
- Source signal traceability
- Contradiction detection and tracking
- Versioning for belief evolution
- Vector representations for similarity and clustering

### 4. COHORTS Schema - Emergent Pattern Discovery

**Purpose**: Discovered clusters through unsupervised learning with dynamic evolution tracking.

**Key Tables**:
- `cohorts` - Discovered clusters with characteristics and stability metrics
- `actor_cohort_membership` - Many-to-many relationship with confidence scores
- `cohort_evolution_log` - Complete history of cohort changes
- `clustering_runs` - Metadata about each clustering execution
- `cohort_characteristics` - Detailed characteristics that define each cohort
- `cohort_similarity_matrix` - Precomputed similarity scores between cohorts
- `cohort_performance_metrics` - Performance tracking for cohorts over time

**Design Principles**:
- No predefined clusters - all emerge from data
- Dynamic evolution through splits, merges, dissolutions
- Confidence scoring for membership assignments
- Stability and coherence metrics
- Complete evolution history tracking
- Performance measurement and comparison

### 5. STIMULI Schema - Outbound Responses

**Purpose**: Generated offers, campaigns, and messages targeted at specific cohorts or actors.

**Key Tables**:
- `stimuli_base` - Base table for all stimulus types with common fields
- `offers` - Specific offers and promotions with terms and conditions
- `campaigns` - Marketing campaigns with A/B testing and targeting
- `messages` - Individual messages with personalization and delivery settings
- `stimulus_deployments` - Actual deployments of stimuli to actors
- `stimulus_templates` - Reusable templates for generating stimuli
- `stimulus_performance_metrics` - Detailed performance tracking

**Design Principles**:
- Flexible content storage using JSONB
- Targeting at cohort or actor level
- Reasoning traceability for each stimulus
- Performance tracking and optimization
- Template system for reusability
- A/B testing support

### 6. OPS Schema - Internal Operations

**Purpose**: Internal business operations including sites, sales, inventory, and metrics.

**Key Tables**:
- `sites` - Physical and virtual locations with operational details
- `sales_data` - Sales transactions with customer and financial information
- `inventory` - Product inventory management with stock levels
- `supply_chain` - Supplier and vendor management with performance metrics
- `crm_events` - Customer relationship management events
- `business_metrics` - Key business performance indicators
- `operational_alerts` - System alerts and notifications

**Design Principles**:
- Multi-site support with location tracking
- Complete transaction history
- Inventory management with reorder points
- Supplier performance tracking
- Business metrics with time-series data
- Alert system for operational issues

### 7. OUTCOMES Schema - Results Tracking

**Purpose**: Track results and outcomes of stimuli deployment for learning and improvement.

**Key Tables**:
- `outcomes` - Central outcomes tracking with full traceability
- `cohort_outcome_summary` - Aggregate outcome data by cohort
- `outcome_analysis` - Detailed analysis of outcome patterns
- `outcome_learning` - What the system learned from outcomes
- `outcome_feedback_loop` - Track how outcomes feed back into the system

**Design Principles**:
- Full traceability to source stimuli
- Attribution confidence scoring
- Statistical analysis and comparison
- Learning from outcomes
- Feedback loop implementation
- Quality and reliability metrics

### 8. AI Schema - Reasoning & Learning

**Purpose**: AI reasoning and learning capabilities - the brain of the system.

**Key Tables**:
- `functions` - Registry of all logic functions used by the system
- `function_calls` - Log of every function execution with performance metrics
- `reasoning_logs` - Detailed reasoning behind every decision
- `learning_logs` - What the system learned and how it updated knowledge
- `contradiction_logs` - Track when beliefs conflict with behavior
- `ai_system_state` - Current state of the AI system for monitoring

**Design Principles**:
- Complete function registry with performance tracking
- Detailed reasoning traceability
- Learning from experience
- Contradiction detection and resolution
- System health monitoring
- Quality and confidence scoring

## Key Relationships

### Primary Data Flow
```
SIGNALS → ACTORS → COHORTS → STIMULI → OUTCOMES → LEARNING → ACTORS
```

### Cross-Schema Dependencies
- All schemas reference `core.brands` for multi-tenancy
- Signals link to actors through `actor_id`
- Actors link to cohorts through membership table
- Stimuli target cohorts or individual actors
- Outcomes trace back to stimuli and actors
- AI functions process data across all schemas

### Foreign Key Relationships
- `brand_id` appears in all tables for tenant isolation
- `actor_id` links signals, outcomes, and actor-related data
- `cohort_id` links cohorts to memberships and stimuli
- `stimulus_id` links stimuli to outcomes and deployments
- `function_id` links functions to their execution logs

## Data Types and Patterns

### Confidence Scoring
- All confidence scores are FLOAT values between 0 and 1
- 0 = no confidence, 1 = complete confidence
- Used for beliefs, memberships, outcomes, and decisions

### JSONB Usage
- Flexible data storage for evolving requirements
- Used for settings, metadata, content, and complex structures
- Indexed with GIN indexes for efficient querying

### Timestamp Patterns
- `created_at` - When record was first created
- `updated_at` - When record was last modified
- `*_at` - Specific event timestamps
- All timestamps use TIMESTAMPTZ for timezone awareness

### Versioning
- Many tables include `version` and `is_current` fields
- Allows tracking of belief evolution over time
- Enables rollback and historical analysis

## Performance Considerations

### Indexing Strategy
- Primary keys on all tables
- Foreign key indexes for joins
- Composite indexes for common query patterns
- Partial indexes for filtered queries
- GIN indexes for JSONB and full-text search
- Vector similarity indexes for clustering

### Query Optimization
- Brand-scoped queries use `brand_id` filters
- Time-based queries use timestamp indexes
- Quality-based queries use confidence score indexes
- Text search uses full-text search indexes

### Data Retention
- Audit logs are append-only and permanent
- Historical data is versioned, not deleted
- Cleanup indexes identify old data for archival
- Performance monitoring tracks query performance

## Security Model

### Row Level Security (RLS)
- Service role has full access to all data
- Authenticated users can only access their brand's data
- Audit trails are append-only for all users
- Global functions are accessible to all brands

### Data Isolation
- Every table includes `brand_id` for tenant isolation
- RLS policies enforce brand boundaries
- Cross-brand data access is prevented
- Audit logs track all data access

### Access Control
- Role-based permissions in user management
- Function-level access control
- API key management for external access
- Complete audit trail for compliance

## Extensibility

### Adding New Signal Types
1. Create new table extending `signals_base`
2. Add signal type to base table constraint
3. Update processing functions
4. Add to signal processing pipeline

### Adding New Actor Attributes
1. Add to appropriate actor table
2. Update belief update functions
3. Add to clustering algorithms
4. Update vector generation

### Adding New Cohort Algorithms
1. Register function in `ai.functions`
2. Add algorithm to clustering runs
3. Update cohort assignment logic
4. Add performance metrics

### Adding New Stimulus Types
1. Create new table extending `stimuli_base`
2. Add stimulus type to base table constraint
3. Update generation functions
4. Add to deployment pipeline

## Monitoring and Maintenance

### System Health
- Function call performance tracking
- Error rate monitoring
- Memory and CPU usage tracking
- Database performance metrics

### Data Quality
- Confidence score distributions
- Evidence count tracking
- Contradiction detection
- Learning effectiveness metrics

### Business Metrics
- Actor engagement levels
- Cohort performance over time
- Stimulus effectiveness rates
- Outcome attribution accuracy

## Future Enhancements

### Phase 2: Signal Intake
- Real-time signal processing
- External API integrations
- Signal quality validation
- Duplicate detection algorithms

### Phase 3: Intelligence
- Advanced clustering algorithms
- Machine learning model integration
- Predictive analytics
- Automated decision making

### Phase 4: Stimulus Generation
- AI-powered content creation
- Dynamic personalization
- Multi-channel orchestration
- A/B testing automation

### Phase 5: Loop Closure
- Automated outcome processing
- Learning from failures
- System self-optimization
- Continuous improvement

---

This schema represents the foundation of a self-aware business operating system that learns, adapts, and grows with your business. Every design decision supports the core philosophy of probabilistic thinking, emergent patterns, and continuous learning.
