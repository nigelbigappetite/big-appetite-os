-- =====================================================
-- DRIVER CONFLICT MATRICES & QUANTUM DYNAMICS
-- Phase 2: Populate comprehensive driver relationships
-- =====================================================

-- =====================================================
-- POPULATE ENHANCED DRIVER ONTOLOGY WITH CONFLICT MATRICES
-- =====================================================

INSERT INTO actors.drivers (
  driver_name, core_meaning, core_need, emotional_tone,
  typical_behaviors, language_patterns, friction_indicators,
  driver_dynamics, stimuli_cues, description, examples
) VALUES

-- =====================================================
-- SAFETY DRIVER (Buffer)
-- =====================================================
(
  'Safety',
  'Safety, comfort, predictability, security',
  'Security',
  'Calm, reassured, stable, protected',
  ARRAY[
    'Orders same items repeatedly',
    'Complains about inconsistency',
    'Expresses concern about changes',
    'Seeks reassurance before trying new things',
    'Values reliability and consistency',
    'Asks about ingredients and preparation',
    'Prefers familiar environments',
    'Avoids risky or unknown options'
  ],
  ARRAY[
    'always get the same',
    'usually order',
    'reliable',
    'consistent',
    'what I know',
    'comfortable with',
    'safe choice',
    'trusted',
    'never disappoints',
    'exactly what I expect',
    'same as always',
    'dependable'
  ],
  ARRAY[
    'Mentions inconsistency',
    'Complains about changes',
    'Expresses uncertainty',
    'Worried about quality variation',
    'Seeks excessive reassurance',
    'Avoids new experiences'
  ],
  '{
    "conflicts_with": [
      {
        "driver": "Freedom",
        "conflict_strength": 0.85,
        "tension_manifestation": "Predictability vs spontaneity",
        "common_behavioral_patterns": [
          "Orders familiar items but expresses curiosity about new options",
          "Seeks reassurance before trying something different",
          "Desires routine but feels constrained",
          "Wants to explore but needs safety net"
        ],
        "collapse_strategies": [
          "Familiar innovation - new items positioned as extensions of known favorites",
          "Gradual exploration - step-by-step introduction to variety",
          "Safety-first adventure - risk mitigation with novelty",
          "Trusted variety - new options from trusted sources"
        ]
      },
      {
        "driver": "Status",
        "conflict_strength": 0.68,
        "tension_manifestation": "Comfort vs recognition",
        "common_behavioral_patterns": [
          "Wants reliable choices but seeks premium positioning",
          "Values consistency but desires exclusivity",
          "Prefers tested options but wants to appear sophisticated",
          "Seeks comfort but needs social validation"
        ],
        "collapse_strategies": [
          "Reliable prestige - position classics as premium",
          "Consistent quality signaling - emphasize craftsmanship in familiar items",
          "Heritage status - tradition as exclusivity marker",
          "Comfortable sophistication - familiar luxury"
        ]
      },
      {
        "driver": "Growth",
        "conflict_strength": 0.72,
        "tension_manifestation": "Stability vs development",
        "common_behavioral_patterns": [
          "Wants to improve but fears failure",
          "Seeks mastery but avoids challenges",
          "Desires progress but needs security",
          "Values learning but wants guaranteed success"
        ],
        "collapse_strategies": [
          "Safe growth - low-risk skill development",
          "Incremental mastery - small, guaranteed improvements",
          "Protected learning - failure-proof skill building",
          "Secure progression - advancement without risk"
        ]
      }
    ],
    "reinforces_with": [
      {
        "driver": "Connection",
        "reinforcement_strength": 0.82,
        "synergy_manifestation": "Shared comfort and belonging",
        "amplification_pattern": "Safety + Connection creates loyalty and community attachment"
      }
    ],
    "entanglement_patterns": {
      "quantum_correlation": "When Safety is high, Growth is suppressed (-0.72 correlation)",
      "measurement_effect": "Observing Safety behaviors strengthens Safety driver (reinforcement loop)",
      "complementarity": "Cannot be simultaneously high in Safety and Freedom (uncertainty principle)",
      "interference_pattern": "Safety and Status create destructive interference in social contexts"
    }
  }'::jsonb,
  '{
    "messaging_tone": "reassuring",
    "offer_types": ["loyalty rewards", "consistency guarantees", "familiar options"],
    "content_themes": ["reliability", "trust", "same great quality", "dependable"],
    "visual_cues": ["warm colors", "comfortable imagery", "familiar settings"],
    "language_style": "warm, personal, reassuring"
  }'::jsonb,
  'Seeks stability and predictability. Values knowing what to expect. Uncomfortable with change or inconsistency. Needs reassurance and security.',
  ARRAY[
    'Always orders the same wings',
    'Asks "Is this the same as last time?"',
    'Values consistency over variety',
    'Seeks comfort in familiar choices'
  ]
),

-- =====================================================
-- CONNECTION DRIVER (Bond)
-- =====================================================
(
  'Connection',
  'Belonging, trust, shared experience, warmth, community',
  'Intimacy',
  'Warm, connected, appreciated, loved',
  ARRAY[
    'Orders for family and friends',
    'Shares experiences and photos',
    'Engages in social eating',
    'Seeks community and belonging',
    'Values shared experiences',
    'Recommends to others',
    'Creates traditions and rituals',
    'Builds relationships through food'
  ],
  ARRAY[
    'our favorite',
    'like my family makes',
    'everyone loved it',
    'brings us together',
    'shared experience',
    'family tradition',
    'we always get',
    'perfect for sharing',
    'brings back memories',
    'reminds me of home'
  ],
  ARRAY[
    'Feels excluded or left out',
    'Disappointed by social experience',
    'Lonely or isolated feeling',
    'Lacks connection with others'
  ],
  '{
    "conflicts_with": [
      {
        "driver": "Freedom",
        "conflict_strength": 0.54,
        "tension_manifestation": "Belonging vs independence",
        "common_behavioral_patterns": [
          "Wants to belong but needs personal space",
          "Seeks connection but values autonomy",
          "Desires community but fears losing self",
          "Values relationships but needs individuality"
        ],
        "collapse_strategies": [
          "Independent togetherness - connection that preserves autonomy",
          "Personal community - belonging without conformity",
          "Chosen family - relationships based on choice not obligation",
          "Authentic connection - real relationships not forced ones"
        ]
      },
      {
        "driver": "Status",
        "conflict_strength": 0.61,
        "tension_manifestation": "Intimacy vs recognition",
        "common_behavioral_patterns": [
          "Wants deep connection but seeks validation",
          "Values authenticity but needs social proof",
          "Desires real relationships but wants to be seen",
          "Seeks belonging but needs distinction"
        ],
        "collapse_strategies": [
          "Authentic status - recognition for real connection",
          "Intimate prestige - exclusivity through depth",
          "Genuine distinction - being known for being real",
          "Meaningful recognition - status through authenticity"
        ]
      }
    ],
    "reinforces_with": [
      {
        "driver": "Safety",
        "reinforcement_strength": 0.82,
        "synergy_manifestation": "Shared comfort and belonging",
        "amplification_pattern": "Safety + Connection creates loyalty and community attachment"
      },
      {
        "driver": "Purpose",
        "reinforcement_strength": 0.75,
        "synergy_manifestation": "Meaningful relationships and shared values",
        "amplification_pattern": "Connection + Purpose creates deep, value-aligned relationships"
      }
    ],
    "entanglement_patterns": {
      "quantum_correlation": "When Connection is high, Freedom is suppressed (-0.54 correlation)",
      "measurement_effect": "Social observation strengthens Connection driver",
      "complementarity": "Cannot be simultaneously high in Connection and Status (social vs personal)",
      "interference_pattern": "Connection and Status create constructive interference in intimate contexts"
    }
  }'::jsonb,
  '{
    "messaging_tone": "warm, personal, inclusive",
    "offer_types": ["family meals", "sharing platters", "group experiences", "community events"],
    "content_themes": ["togetherness", "sharing", "family", "community", "memories"],
    "visual_cues": ["people together", "warm lighting", "family scenes", "shared moments"],
    "language_style": "personal, warm, inclusive"
  }'::jsonb,
  'Seeks belonging and meaningful relationships. Values shared experiences and community. Wants to feel connected and appreciated.',
  ARRAY[
    'Orders for the whole family',
    'Shares photos of meals',
    'Creates dining traditions',
    'Values shared experiences'
  ]
),

-- =====================================================
-- STATUS DRIVER (Badge)
-- =====================================================
(
  'Status',
  'Recognition, distinction, being seen, social proof, validation',
  'Respect',
  'Proud, validated, recognized, distinguished',
  ARRAY[
    'Photographs and shares food',
    'Seeks premium or exclusive options',
    'Displays brand loyalty publicly',
    'Writes reviews and recommendations',
    'Seeks recognition and validation',
    'Chooses trendy or popular items',
    'Values social proof and popularity',
    'Seeks distinction and uniqueness'
  ],
  ARRAY[
    'premium',
    'exclusive',
    'best',
    'impressed',
    'special',
    'trendy',
    'popular',
    'everyone is talking about',
    'must try',
    'highly recommended',
    'top rated',
    'award winning'
  ],
  ARRAY[
    'Feels unrecognized or undervalued',
    'Disappointed by lack of distinction',
    'Worried about social standing',
    'Seeks validation but doesn''t receive it'
  ],
  '{
    "conflicts_with": [
      {
        "driver": "Safety",
        "conflict_strength": 0.68,
        "tension_manifestation": "Recognition vs comfort",
        "common_behavioral_patterns": [
          "Wants to be seen but needs security",
          "Seeks distinction but values reliability",
          "Desires recognition but fears failure",
          "Values status but needs predictability"
        ],
        "collapse_strategies": [
          "Reliable prestige - status through consistency",
          "Safe distinction - recognition without risk",
          "Predictable status - reliable ways to be seen",
          "Secure recognition - guaranteed validation"
        ]
      },
      {
        "driver": "Connection",
        "conflict_strength": 0.61,
        "tension_manifestation": "Recognition vs intimacy",
        "common_behavioral_patterns": [
          "Wants to be seen but needs deep connection",
          "Seeks validation but values authenticity",
          "Desires distinction but wants belonging",
          "Values recognition but needs real relationships"
        ],
        "collapse_strategies": [
          "Authentic status - recognition for being real",
          "Intimate prestige - distinction through depth",
          "Genuine recognition - validation for authenticity",
          "Meaningful distinction - status through connection"
        ]
      },
      {
        "driver": "Purpose",
        "conflict_strength": 0.73,
        "tension_manifestation": "Recognition vs meaning",
        "common_behavioral_patterns": [
          "Wants to be seen but needs purpose",
          "Seeks validation but values meaning",
          "Desires distinction but wants significance",
          "Values recognition but needs depth"
        ],
        "collapse_strategies": [
          "Meaningful status - recognition for purpose",
          "Purposeful distinction - status through meaning",
          "Significant recognition - validation for values",
          "Deep prestige - distinction through purpose"
        ]
      }
    ],
    "reinforces_with": [
      {
        "driver": "Freedom",
        "reinforcement_strength": 0.65,
        "synergy_manifestation": "Uniqueness creates distinction",
        "amplification_pattern": "Freedom + Status creates unique recognition"
      },
      {
        "driver": "Growth",
        "reinforcement_strength": 0.58,
        "synergy_manifestation": "Mastery leads to recognition",
        "amplification_pattern": "Growth + Status creates expertise-based distinction"
      }
    ],
    "entanglement_patterns": {
      "quantum_correlation": "When Status is high, Connection is suppressed (-0.61 correlation)",
      "measurement_effect": "Public observation strengthens Status driver",
      "complementarity": "Cannot be simultaneously high in Status and Purpose (external vs internal validation)",
      "interference_pattern": "Status and Purpose create destructive interference in private contexts"
    }
  }'::jsonb,
  '{
    "messaging_tone": "aspirational, confident, exclusive",
    "offer_types": ["premium options", "exclusive access", "limited editions", "VIP experiences"],
    "content_themes": ["excellence", "distinction", "recognition", "prestige", "exclusivity"],
    "visual_cues": ["luxury imagery", "premium presentation", "exclusive settings", "recognition symbols"],
    "language_style": "confident, aspirational, exclusive"
  }'::jsonb,
  'Seeks recognition and social validation. Wants to be seen and distinguished. Values status and social proof.',
  ARRAY[
    'Shares photos of premium meals',
    'Seeks exclusive or limited options',
    'Values brand recognition',
    'Writes public reviews'
  ]
),

-- =====================================================
-- GROWTH DRIVER (Build)
-- =====================================================
(
  'Growth',
  'Mastery, improvement, learning, progression, development',
  'Competence',
  'Accomplished, progressing, capable, empowered',
  ARRAY[
    'Tries new and challenging options',
    'Seeks to expand palate and skills',
    'Takes on difficult or complex orders',
    'Values learning and development',
    'Seeks mastery and expertise',
    'Tracks progress and improvement',
    'Challenges themselves regularly',
    'Values feedback and improvement'
  ],
  ARRAY[
    'trying to',
    'building my tolerance',
    'getting better at',
    'learning',
    'improving',
    'mastering',
    'challenging myself',
    'expanding my',
    'developing my',
    'progressing',
    'next level',
    'level up'
  ],
  ARRAY[
    'Feels stuck or stagnant',
    'Disappointed by lack of progress',
    'Frustrated by slow improvement',
    'Worried about not growing'
  ],
  '{
    "conflicts_with": [
      {
        "driver": "Safety",
        "conflict_strength": 0.72,
        "tension_manifestation": "Development vs stability",
        "common_behavioral_patterns": [
          "Wants to improve but fears failure",
          "Seeks mastery but needs security",
          "Desires progress but wants predictability",
          "Values learning but avoids risk"
        ],
        "collapse_strategies": [
          "Safe growth - low-risk skill development",
          "Incremental mastery - small, guaranteed improvements",
          "Protected learning - failure-proof skill building",
          "Secure progression - advancement without risk"
        ]
      },
      {
        "driver": "Connection",
        "conflict_strength": 0.48,
        "tension_manifestation": "Individual development vs shared experience",
        "common_behavioral_patterns": [
          "Wants to grow but needs social support",
          "Seeks mastery but values relationships",
          "Desires progress but wants belonging",
          "Values learning but needs connection"
        ],
        "collapse_strategies": [
          "Shared growth - learning together",
          "Community mastery - development through connection",
          "Collective progress - advancement with others",
          "Relational learning - growth through relationships"
        ]
      }
    ],
    "reinforces_with": [
      {
        "driver": "Freedom",
        "reinforcement_strength": 0.78,
        "synergy_manifestation": "Exploration enables mastery",
        "amplification_pattern": "Freedom + Growth creates adventurous learning"
      },
      {
        "driver": "Status",
        "reinforcement_strength": 0.58,
        "synergy_manifestation": "Mastery leads to recognition",
        "amplification_pattern": "Growth + Status creates expertise-based distinction"
      },
      {
        "driver": "Purpose",
        "reinforcement_strength": 0.71,
        "synergy_manifestation": "Development serves meaning",
        "amplification_pattern": "Growth + Purpose creates purposeful mastery"
      }
    ],
    "entanglement_patterns": {
      "quantum_correlation": "When Growth is high, Safety is suppressed (-0.72 correlation)",
      "measurement_effect": "Achievement observation strengthens Growth driver",
      "complementarity": "Cannot be simultaneously high in Growth and Safety (risk vs security)",
      "interference_pattern": "Growth and Safety create destructive interference in comfort contexts"
    }
  }'::jsonb,
  '{
    "messaging_tone": "encouraging, challenging, empowering",
    "offer_types": ["challenging options", "skill-building experiences", "progressive menus", "mastery programs"],
    "content_themes": ["improvement", "mastery", "challenge", "progress", "development"],
    "visual_cues": ["progression imagery", "skill development", "achievement symbols", "growth metaphors"],
    "language_style": "encouraging, challenging, empowering"
  }'::jsonb,
  'Seeks mastery and continuous improvement. Values learning and development. Wants to grow and become more capable.',
  ARRAY[
    'Tries increasingly spicy options',
    'Seeks complex flavor combinations',
    'Values skill development',
    'Tracks progress over time'
  ]
),

-- =====================================================
-- FREEDOM DRIVER (Breadth)
-- =====================================================
(
  'Freedom',
  'Exploration, variety, novelty, independence, spontaneity',
  'Autonomy',
  'Excited, liberated, curious, adventurous',
  ARRAY[
    'Explores new menu options regularly',
    'Seeks variety and novelty',
    'Makes spontaneous choices',
    'Values independence and autonomy',
    'Tries different combinations',
    'Seeks unique experiences',
    'Values personal choice',
    'Avoids routine and repetition'
  ],
  ARRAY[
    'new',
    'different',
    'never tried',
    'change it up',
    'explore',
    'variety',
    'something different',
    'mix it up',
    'try something new',
    'adventure',
    'spontaneous',
    'whatever catches my eye'
  ],
  ARRAY[
    'Feels constrained or limited',
    'Bored by repetition',
    'Frustrated by lack of options',
    'Worried about being trapped'
  ],
  '{
    "conflicts_with": [
      {
        "driver": "Safety",
        "conflict_strength": 0.85,
        "tension_manifestation": "Exploration vs security",
        "common_behavioral_patterns": [
          "Wants to explore but needs security",
          "Seeks novelty but values predictability",
          "Desires variety but wants reliability",
          "Values freedom but needs comfort"
        ],
        "collapse_strategies": [
          "Safe exploration - novelty with security",
          "Guided adventure - freedom with support",
          "Secure variety - new options with guarantees",
          "Protected freedom - autonomy with safety nets"
        ]
      },
      {
        "driver": "Connection",
        "conflict_strength": 0.54,
        "tension_manifestation": "Independence vs belonging",
        "common_behavioral_patterns": [
          "Wants freedom but needs connection",
          "Seeks autonomy but values relationships",
          "Desires independence but wants belonging",
          "Values personal choice but needs community"
        ],
        "collapse_strategies": [
          "Independent togetherness - freedom within connection",
          "Personal community - autonomy with belonging",
          "Chosen freedom - relationships that support independence",
          "Authentic autonomy - real choice within relationships"
        ]
      },
      {
        "driver": "Purpose",
        "conflict_strength": 0.67,
        "tension_manifestation": "Exploration vs meaning",
        "common_behavioral_patterns": [
          "Wants freedom but needs purpose",
          "Seeks variety but values meaning",
          "Desires exploration but wants significance",
          "Values autonomy but needs direction"
        ],
        "collapse_strategies": [
          "Purposeful freedom - exploration with meaning",
          "Meaningful variety - choice that matters",
          "Significant exploration - freedom that serves purpose",
          "Directed autonomy - independence with values"
        ]
      }
    ],
    "reinforces_with": [
      {
        "driver": "Growth",
        "reinforcement_strength": 0.78,
        "synergy_manifestation": "Exploration enables mastery",
        "amplification_pattern": "Freedom + Growth creates adventurous learning"
      },
      {
        "driver": "Status",
        "reinforcement_strength": 0.65,
        "synergy_manifestation": "Uniqueness creates distinction",
        "amplification_pattern": "Freedom + Status creates unique recognition"
      }
    ],
    "entanglement_patterns": {
      "quantum_correlation": "When Freedom is high, Safety is suppressed (-0.85 correlation)",
      "measurement_effect": "Choice observation strengthens Freedom driver",
      "complementarity": "Cannot be simultaneously high in Freedom and Safety (exploration vs security)",
      "interference_pattern": "Freedom and Safety create destructive interference in comfort contexts"
    }
  }'::jsonb,
  '{
    "messaging_tone": "exciting, adventurous, liberating",
    "offer_types": ["new options", "variety packs", "exploration menus", "adventure experiences"],
    "content_themes": ["discovery", "adventure", "variety", "freedom", "exploration"],
    "visual_cues": ["diverse imagery", "adventure themes", "variety displays", "freedom symbols"],
    "language_style": "exciting, adventurous, liberating"
  }'::jsonb,
  'Seeks variety and new experiences. Values freedom and autonomy. Wants to explore and discover new things.',
  ARRAY[
    'Tries new menu items regularly',
    'Seeks variety in orders',
    'Values personal choice',
    'Avoids routine patterns'
  ]
),

-- =====================================================
-- PURPOSE DRIVER (Meaning)
-- =====================================================
(
  'Purpose',
  'Meaning, values alignment, contribution, significance, impact',
  'Significance',
  'Fulfilled, meaningful, aligned, purposeful',
  ARRAY[
    'Chooses based on values and principles',
    'Seeks ethical and sustainable options',
    'Values brand mission and values',
    'Makes choices that align with beliefs',
    'Seeks meaningful experiences',
    'Values contribution and impact',
    'Chooses based on deeper meaning',
    'Seeks authenticity and integrity'
  ],
  ARRAY[
    'supports',
    'ethical',
    'sustainable',
    'matters',
    'stands for',
    'values',
    'principles',
    'meaningful',
    'purpose',
    'contribution',
    'impact',
    'authentic'
  ],
  ARRAY[
    'Feels disconnected from values',
    'Disappointed by lack of meaning',
    'Frustrated by superficial choices',
    'Worried about not making a difference'
  ],
  '{
    "conflicts_with": [
      {
        "driver": "Status",
        "conflict_strength": 0.73,
        "tension_manifestation": "Meaning vs recognition",
        "common_behavioral_patterns": [
          "Wants purpose but needs recognition",
          "Seeks meaning but values validation",
          "Desires significance but wants to be seen",
          "Values authenticity but needs social proof"
        ],
        "collapse_strategies": [
          "Meaningful status - recognition for purpose",
          "Purposeful distinction - status through meaning",
          "Significant recognition - validation for values",
          "Deep prestige - distinction through purpose"
        ]
      },
      {
        "driver": "Freedom",
        "conflict_strength": 0.67,
        "tension_manifestation": "Purpose vs exploration",
        "common_behavioral_patterns": [
          "Wants purpose but needs freedom",
          "Seeks meaning but values variety",
          "Desires significance but wants exploration",
          "Values direction but needs autonomy"
        ],
        "collapse_strategies": [
          "Purposeful freedom - exploration with meaning",
          "Meaningful variety - choice that matters",
          "Significant exploration - freedom that serves purpose",
          "Directed autonomy - independence with values"
        ]
      },
      {
        "driver": "Safety",
        "conflict_strength": 0.58,
        "tension_manifestation": "Purpose vs comfort",
        "common_behavioral_patterns": [
          "Wants purpose but needs security",
          "Seeks meaning but values predictability",
          "Desires significance but wants comfort",
          "Values direction but needs stability"
        ],
        "collapse_strategies": [
          "Secure purpose - meaning with stability",
          "Comfortable significance - purpose without risk",
          "Stable meaning - direction with security",
          "Protected purpose - values with guarantees"
        ]
      }
    ],
    "reinforces_with": [
      {
        "driver": "Connection",
        "reinforcement_strength": 0.75,
        "synergy_manifestation": "Meaningful relationships and shared values",
        "amplification_pattern": "Connection + Purpose creates deep, value-aligned relationships"
      },
      {
        "driver": "Growth",
        "reinforcement_strength": 0.71,
        "synergy_manifestation": "Development serves meaning",
        "amplification_pattern": "Growth + Purpose creates purposeful mastery"
      }
    ],
    "entanglement_patterns": {
      "quantum_correlation": "When Purpose is high, Status is suppressed (-0.73 correlation)",
      "measurement_effect": "Values observation strengthens Purpose driver",
      "complementarity": "Cannot be simultaneously high in Purpose and Status (internal vs external validation)",
      "interference_pattern": "Purpose and Status create destructive interference in social contexts"
    }
  }'::jsonb,
  '{
    "messaging_tone": "inspiring, authentic, meaningful",
    "offer_types": ["values-aligned options", "sustainable choices", "meaningful experiences", "purpose-driven products"],
    "content_themes": ["values", "purpose", "meaning", "authenticity", "impact"],
    "visual_cues": ["authentic imagery", "values symbols", "meaningful scenes", "purpose themes"],
    "language_style": "inspiring, authentic, meaningful"
  }'::jsonb,
  'Seeks meaning and values alignment. Wants to make choices that matter and contribute to something greater.',
  ARRAY[
    'Chooses based on brand values',
    'Seeks ethical options',
    'Values authenticity',
    'Makes meaningful choices'
  ]
);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check driver conflict matrices
SELECT 
  driver_name,
  jsonb_pretty(driver_dynamics) as conflict_matrix
FROM actors.drivers
ORDER BY driver_name;

-- Test conflict strength calculations
SELECT 
  d1.driver_name as driver_a,
  d2.driver_name as driver_b,
  (d1.driver_dynamics->'conflicts_with'->0->>'conflict_strength')::FLOAT as conflict_strength
FROM actors.drivers d1
CROSS JOIN actors.drivers d2
WHERE d1.driver_name = 'Safety' 
  AND d2.driver_name = 'Freedom';

-- Check entanglement patterns
SELECT 
  driver_name,
  driver_dynamics->'entanglement_patterns' as quantum_dynamics
FROM actors.drivers
WHERE driver_dynamics->'entanglement_patterns' IS NOT NULL;
