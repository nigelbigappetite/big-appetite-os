# Big Appetite OS - Entity Relationship Diagram

## Overview

This document provides a visual representation of the database schema relationships and data flow in Big Appetite OS. The system implements a closed-loop learning architecture where signals flow through actors, cohorts, stimuli, and outcomes, with AI reasoning and learning connecting all components.

## Core Data Flow

```
SIGNALS → ACTORS → COHORTS → STIMULI → OUTCOMES → LEARNING → ACTORS
    ↓        ↓        ↓        ↓        ↓         ↓
   AI ←──────┴────────┴────────┴────────┴─────────┘
```

## Schema Relationships

### 1. CORE Schema (Foundation)

```
core.brands (1) ──→ (M) core.users
     │
     ├── (M) core.brand_settings
     ├── (M) core.brand_integrations
     └── (M) core.audit_log

core.system_parameters (Global, no brand relationship)
```

**Key Relationships**:
- `brands` is the central tenant isolation point
- All other schemas reference `brands.brand_id`
- `users` are scoped to specific brands
- `audit_log` tracks changes across all schemas

### 2. SIGNALS Schema (Input Layer)

```
signals.signals_base (1) ──→ (1) signals.whatsapp_messages
     │                        ├── (1) signals.reviews
     │                        ├── (1) signals.social_comments
     │                        ├── (1) signals.order_history
     │                        ├── (1) signals.web_behavior
     │                        ├── (1) signals.email_interactions
     │                        ├── (1) signals.survey_responses
     │                        └── (1) signals.crm_events
     │
     ├── (M) core.brands
     └── (M) actors.actors
```

**Key Relationships**:
- `signals_base` contains common fields for all signal types
- Each signal type has its own specialized table
- Signals link to actors through `actor_id`
- All signals belong to a specific brand

### 3. ACTORS Schema (Understanding Layer)

```
actors.actors (1) ──→ (M) actors.actor_demographics
     │                  ├── (M) actors.actor_identity_beliefs
     │                  ├── (M) actors.actor_behavioral_scores
     │                  ├── (M) actors.actor_communication_profiles
     │                  ├── (M) actors.actor_psychological_triggers
     │                  ├── (M) actors.actor_preferences
     │                  ├── (M) actors.actor_memory_loops
     │                  ├── (M) actors.actor_friction_points
     │                  ├── (M) actors.actor_contradictions
     │                  ├── (M) actors.actor_belief_vectors
     │                  └── (M) actors.actor_clustering_metadata
     │
     ├── (M) core.brands
     └── (M) signals.signals_base
```

**Key Relationships**:
- `actors` is the central registry for all people
- Each actor has multiple belief and preference tables
- All actor data is versioned with `is_current` flags
- Actors link to signals through `actor_id`
- Belief vectors enable clustering and similarity

### 4. COHORTS Schema (Pattern Discovery)

```
cohorts.cohorts (1) ──→ (M) cohorts.actor_cohort_membership (M) ──→ (1) actors.actors
     │                        │
     ├── (M) cohorts.cohort_characteristics
     ├── (M) cohorts.cohort_evolution_log
     ├── (M) cohorts.cohort_similarity_matrix
     └── (M) cohorts.cohort_performance_metrics
     │
     ├── (M) core.brands
     └── (M) cohorts.clustering_runs
```

**Key Relationships**:
- `cohorts` are discovered through clustering algorithms
- `actor_cohort_membership` is many-to-many with confidence scores
- Cohorts evolve over time with complete history tracking
- Similarity matrices enable cohort relationship analysis
- Performance metrics track cohort effectiveness

### 5. STIMULI Schema (Action Layer)

```
stimuli.stimuli_base (1) ──→ (1) stimuli.offers
     │                        ├── (1) stimuli.campaigns
     │                        ├── (1) stimuli.messages
     │                        └── (1) stimuli.stimulus_deployments
     │
     ├── (M) core.brands
     ├── (M) cohorts.cohorts
     ├── (M) actors.actors
     └── (M) ai.reasoning_logs

stimuli.stimulus_templates (M) ──→ (1) core.brands
stimuli.stimulus_performance_metrics (M) ──→ (1) stimuli.stimuli_base
```

**Key Relationships**:
- `stimuli_base` contains common fields for all stimulus types
- Stimuli can target cohorts or individual actors
- Templates enable reusable stimulus generation
- Deployments track actual delivery to actors
- Performance metrics measure effectiveness

### 6. OPS Schema (Operations Layer)

```
ops.sites (1) ──→ (M) ops.sales_data
     │                  ├── (M) ops.inventory
     │                  └── (M) ops.business_metrics
     │
     ├── (M) core.brands
     └── (M) actors.actors (for sales_data)

ops.supply_chain (M) ──→ (1) core.brands
ops.crm_events (M) ──→ (1) core.brands
ops.operational_alerts (M) ──→ (1) core.brands
```

**Key Relationships**:
- `sites` represent physical and virtual locations
- `sales_data` links to actors and sites
- `inventory` tracks product stock levels
- `supply_chain` manages supplier relationships
- Business metrics provide operational insights

### 7. OUTCOMES Schema (Results Layer)

```
outcomes.outcomes (1) ──→ (M) outcomes.cohort_outcome_summary
     │                      ├── (M) outcomes.outcome_analysis
     │                      ├── (M) outcomes.outcome_learning
     │                      └── (M) outcomes.outcome_feedback_loop
     │
     ├── (M) core.brands
     ├── (M) stimuli.stimuli_base
     ├── (M) cohorts.cohorts
     └── (M) actors.actors
```

**Key Relationships**:
- `outcomes` track results of stimuli deployment
- Outcomes link back to source stimuli and target actors/cohorts
- Analysis provides insights into what worked
- Learning updates system knowledge
- Feedback loops close the learning cycle

### 8. AI Schema (Intelligence Layer)

```
ai.functions (1) ──→ (M) ai.function_calls
     │
     ├── (M) core.brands (optional, some functions are global)
     └── (M) ai.ai_system_state

ai.reasoning_logs (M) ──→ (1) core.brands
ai.learning_logs (M) ──→ (1) core.brands
ai.contradiction_logs (M) ──→ (1) core.brands
```

**Key Relationships**:
- `functions` registry tracks all system capabilities
- `function_calls` log every execution with performance metrics
- Reasoning logs track decision-making process
- Learning logs capture knowledge updates
- Contradiction logs track belief conflicts

## Cross-Schema Data Flow

### Signal Processing Flow
```
1. Signal arrives → signals.signals_base
2. Actor matching → actors.actors
3. Belief updates → actors.actor_demographics, etc.
4. Vector updates → actors.actor_belief_vectors
5. Clustering trigger → cohorts.clustering_runs
6. Cohort assignment → cohorts.actor_cohort_membership
```

### Stimulus Generation Flow
```
1. Cohort analysis → cohorts.cohorts
2. Stimulus generation → stimuli.stimuli_base
3. Targeting → cohorts.actor_cohort_membership
4. Deployment → stimuli.stimulus_deployments
5. Outcome tracking → outcomes.outcomes
6. Learning → ai.learning_logs
```

### Learning Loop Flow
```
1. Outcome analysis → outcomes.outcome_analysis
2. Learning extraction → outcomes.outcome_learning
3. Belief updates → actors.actor_demographics
4. Contradiction detection → ai.contradiction_logs
5. System updates → ai.ai_system_state
6. New stimuli → stimuli.stimuli_base
```

## Key Design Patterns

### Multi-Tenancy
- Every table includes `brand_id` for tenant isolation
- RLS policies enforce brand boundaries
- Cross-brand data access is prevented

### Bayesian Thinking
- All beliefs have confidence scores (0-1)
- Evidence count tracking for each belief
- Source signal traceability
- Contradiction detection and resolution

### Emergent Patterns
- Cohorts discovered through clustering, not predefined
- Dynamic evolution through splits, merges, dissolutions
- Confidence scoring for membership assignments
- Complete evolution history tracking

### Full Traceability
- Every decision links to reasoning logs
- Function calls track all algorithm executions
- Learning logs capture knowledge updates
- Audit trails track all changes

### Non-Destructive
- Versioning instead of deletion
- Historical data preservation
- Rollback capabilities
- Evolution tracking

## Performance Considerations

### Indexing Strategy
- Primary keys on all tables
- Foreign key indexes for joins
- Composite indexes for common queries
- Partial indexes for filtered data
- GIN indexes for JSONB and text search
- Vector similarity indexes for clustering

### Query Patterns
- Brand-scoped queries use `brand_id` filters
- Time-based queries use timestamp indexes
- Quality-based queries use confidence scores
- Similarity queries use vector indexes

### Data Retention
- Audit logs are permanent
- Historical data is versioned
- Cleanup indexes identify old data
- Performance monitoring tracks usage

## Security Model

### Access Control
- Service role: Full access to all data
- Authenticated users: Brand-scoped access only
- Audit trails: Append-only for all users
- Global functions: Accessible to all brands

### Data Isolation
- Brand boundaries enforced by RLS
- Cross-brand queries prevented
- Complete audit trail for compliance
- Function-level access control

## Extensibility Points

### Adding New Signal Types
1. Extend `signals_base` with new table
2. Update signal type constraints
3. Add processing functions
4. Update pipeline configuration

### Adding New Actor Attributes
1. Add to appropriate actor table
2. Update belief update functions
3. Add to clustering algorithms
4. Update vector generation

### Adding New Cohort Algorithms
1. Register in `ai.functions`
2. Add to clustering runs
3. Update assignment logic
4. Add performance metrics

### Adding New Stimulus Types
1. Extend `stimuli_base` with new table
2. Update stimulus type constraints
3. Add generation functions
4. Update deployment pipeline

---

This ER diagram represents the complete architecture of Big Appetite OS, showing how data flows through the system to create a self-aware, learning business operating system. Every relationship supports the core philosophy of probabilistic thinking, emergent patterns, and continuous learning.
