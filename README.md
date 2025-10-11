# Big Appetite OS - Phase 1 Foundation

A self-aware, learning business operating system that captures signals from the world, understands them probabilistically, discovers emergent patterns, and continuously improves through feedback.

## 🧠 System Philosophy

Big Appetite OS is built on the principle that businesses should operate like living organisms - constantly sensing their environment, learning from experience, and adapting their behavior. Unlike traditional systems that rely on predefined rules and static data, this system:

- **Thinks in probabilities** - Every belief has a confidence score, not certainty
- **Discovers patterns** - Cohorts emerge from data, not predefined categories  
- **Learns continuously** - Every outcome feeds back into improved understanding
- **Maintains traceability** - Every decision can be traced back to its reasoning
- **Evolves organically** - New capabilities are added incrementally and tracked

## 🏗️ Architecture Overview

The system is organized into **8 core schemas** that work together to create a closed-loop learning system:

### 1. **CORE** - Global Configuration
- Multi-tenant brand isolation
- User management and permissions
- System-wide configuration
- Audit trails and compliance

### 2. **SIGNALS** - Input from the World
- WhatsApp messages, reviews, social comments
- Order history, web behavior, email interactions
- Survey responses, CRM events
- All signals processed for actor matching and insights

### 3. **ACTORS** - Understanding of People
- Bayesian actor profiles with uncertainty modeling
- Demographics, identity beliefs, behavioral scores
- Communication profiles, psychological triggers
- Preferences, memory loops, friction points
- Contradiction tracking and belief vectors

### 4. **COHORTS** - Emergent Patterns
- Discovered clusters through unsupervised learning
- Cohort characteristics and evolution tracking
- Membership assignments with confidence scores
- Similarity matrices and performance metrics

### 5. **STIMULI** - Outbound Responses
- Generated offers, campaigns, messages
- Targeted at specific cohorts or actors
- Templates and deployment tracking
- Performance measurement and optimization

### 6. **OPS** - Internal Operations
- Sites, sales data, inventory management
- Supply chain, CRM events, business metrics
- Operational alerts and monitoring

### 7. **OUTCOMES** - Results Tracking
- Outcome measurement and analysis
- Cohort performance summaries
- Learning insights and feedback loops
- Attribution and causality analysis

### 8. **AI** - Reasoning & Learning
- Function registry and execution tracking
- Reasoning logs and decision traceability
- Learning logs and knowledge updates
- Contradiction detection and resolution

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 15+ with pgvector extension
- Supabase CLI (for local development)
- Node.js 18+ (for future phases)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/big-appetite-os.git
   cd big-appetite-os
   ```

2. **Set up Supabase locally**
   ```bash
   supabase start
   ```

3. **Run migrations**
   ```bash
   supabase db reset
   ```

4. **View the database**
   ```bash
   supabase studio
   ```

### Connecting to Supabase Cloud

If you're using Supabase Cloud instead of local development:

1. **Set up your project**
   - Create a new project at [supabase.com](https://supabase.com)
   - Note your project URL and anon key

2. **Update configuration**
   ```bash
   supabase link --project-ref your-project-ref
   ```

3. **Deploy migrations**
   ```bash
   supabase db push
   ```

## 📊 Sample Data

The system comes with realistic sample data for **Wing Shack**, a Brooklyn-based wing restaurant:

- **5 diverse actors** with different preferences and behaviors
- **20+ mixed signals** from WhatsApp, reviews, orders, and social media
- **2 emergent cohorts** discovered through clustering
- **1 targeted campaign** with measurable outcomes
- **Complete traceability** from signal to outcome

### Sample Actors
- **Sarah** - Spice enthusiast who loves extra hot wings
- **Mike** - Health-conscious customer who prefers grilled options
- **Lisa** - Value seeker who looks for deals and combos
- **Tom** - Social butterfly who brings groups and shares experiences
- **Emma** - Occasional customer with conservative preferences

### Sample Cohorts
- **Spice Enthusiasts** - High heat tolerance, adventure seeking, social sharing
- **Value Seekers** - Price sensitive, deal seeking, combo preference

## 🔍 Key Features

### Bayesian Actor Profiles
Every actor attribute includes:
- **Value** - What we believe about them
- **Confidence** - How certain we are (0-1)
- **Evidence count** - How many signals contributed
- **Source tracking** - Which signals led to this belief

### Emergent Cohort Discovery
- **No predefined segments** - Cohorts emerge from data
- **Dynamic evolution** - Cohorts split, merge, and dissolve
- **Confidence scoring** - How well actors fit their cohorts
- **Performance tracking** - How cohorts respond to stimuli

### Full Traceability
- **Reasoning logs** - Why every decision was made
- **Function calls** - Every algorithm execution tracked
- **Learning logs** - What the system learned and when
- **Contradiction tracking** - When beliefs conflict with behavior

### Self-Aware Learning
- **Outcome feedback** - Results feed back into belief updates
- **Pattern detection** - Automatic discovery of new insights
- **Contradiction resolution** - System identifies and resolves conflicts
- **Continuous improvement** - Every interaction makes the system smarter

## 🛠️ Development

### Schema Design Principles

1. **Bayesian Thinking** - Every belief has confidence, not certainty
2. **Emergent Patterns** - Cohorts discovered, not designed
3. **Full Traceability** - Every decision links to reasoning
4. **Non-destructive** - Use versioning, not deletion
5. **Boundary-aware** - RLS enforces brand isolation
6. **Self-describing** - Metadata makes system interpretable
7. **Loop-ready** - Outcomes feed back as signals

### Database Features

- **Row Level Security** - Brand-scoped access control
- **Vector similarity** - pgvector for cohort clustering
- **Full-text search** - GIN indexes for content search
- **JSONB flexibility** - Evolving data structures
- **Audit trails** - Complete change tracking
- **Performance indexes** - Optimized for common queries

### Function Architecture

The system includes PL/pgSQL functions for:
- **Signal processing** - Actor matching and content analysis
- **Belief updates** - Bayesian inference for actor profiles
- **Clustering** - Cohort discovery and assignment
- **Learning** - Knowledge updates from outcomes
- **Reasoning** - Decision-making and traceability

## 📈 What's Next

### Phase 2: Signal Intake Pipeline
- WhatsApp Business API integration
- Review platform connectors
- Social media monitoring
- Real-time signal processing

### Phase 3: Intelligence Implementation
- Full Bayesian belief updating
- Advanced clustering algorithms
- Contradiction detection and resolution
- Predictive modeling

### Phase 4: Stimulus Generation
- AI-powered campaign creation
- Dynamic content personalization
- A/B testing automation
- Multi-channel orchestration

### Phase 5: Loop Closure
- Outcome measurement and attribution
- Learning from failures and successes
- System self-optimization
- Continuous improvement

## 🤝 Contributing

This is Phase 1 - the foundation. Future phases will build the intelligence layer, integrations, and user interfaces.

### Development Guidelines
- Follow the Bayesian philosophy
- Maintain full traceability
- Test with realistic data
- Document reasoning and decisions
- Preserve system interpretability

## 📄 License

[Add your license here]

## 🆘 Support

For questions about the system architecture or implementation:
- Review the schema documentation in `SCHEMA.md`
- Check the ER diagram in `ER_DIAGRAM.md`
- Examine the sample data in the seed migration
- Study the function implementations

---

**Big Appetite OS** - Where business intelligence meets artificial intelligence, creating a self-aware system that learns, adapts, and grows with your business.
