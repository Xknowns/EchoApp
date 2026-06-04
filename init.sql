-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Memories table with vector embeddings
CREATE TABLE IF NOT EXISTS memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    embedding vector(768),  -- Llama 3.1 8B embedding dimension
    memory_type VARCHAR(50) NOT NULL,  -- EVENT, DECISION, ACTION, PERSON, PROJECT
    source VARCHAR(50) NOT NULL,       -- CALENDAR, SLACK, EMAIL, BROWSER, MANUAL
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    confidence DOUBLE PRECISION DEFAULT 1.0,
    deleted_at TIMESTAMP DEFAULT NULL,

    CONSTRAINT valid_memory_type CHECK (memory_type IN ('EVENT', 'DECISION', 'ACTION', 'PERSON', 'PROJECT', 'TOPIC')),
    CONSTRAINT valid_source CHECK (source IN ('CALENDAR', 'SLACK', 'EMAIL', 'BROWSER', 'MANUAL', 'VOICE', 'PHOTO'))
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_memories_user_id ON memories(user_id);
CREATE INDEX IF NOT EXISTS idx_memories_memory_type ON memories(memory_type);
CREATE INDEX IF NOT EXISTS idx_memories_source ON memories(source);
CREATE INDEX IF NOT EXISTS idx_memories_created_at ON memories(created_at);
CREATE INDEX IF NOT EXISTS idx_memories_user_time ON memories(user_id, created_at DESC);

-- Vector similarity index (IVFFlat for approximate nearest neighbor)
CREATE INDEX IF NOT EXISTS idx_memories_embedding ON memories 
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- GIN index for JSONB metadata queries
CREATE INDEX IF NOT EXISTS idx_memories_metadata ON memories USING GIN (metadata);

-- People/entities extracted from memories
CREATE TABLE IF NOT EXISTS entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,  -- PERSON, ORGANIZATION, PROJECT, LOCATION
    email VARCHAR(255),
    first_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    interaction_count INTEGER DEFAULT 1,
    metadata JSONB DEFAULT '{}',

    CONSTRAINT valid_entity_type CHECK (entity_type IN ('PERSON', 'ORGANIZATION', 'PROJECT', 'LOCATION', 'TOPIC'))
);

CREATE INDEX IF NOT EXISTS idx_entities_user_id ON entities(user_id);
CREATE INDEX IF NOT EXISTS idx_entities_name ON entities(name);
CREATE INDEX IF NOT EXISTS idx_entities_type ON entities(entity_type);

-- Relationships between entities (social graph)
CREATE TABLE IF NOT EXISTS relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    source_entity_id UUID NOT NULL REFERENCES entities(id),
    target_entity_id UUID NOT NULL REFERENCES entities(id),
    relationship_type VARCHAR(50) NOT NULL,  -- WORKS_WITH, MET_AT, DISCUSSED, REPORTS_TO
    strength DOUBLE PRECISION DEFAULT 0.5,  -- 0.0 to 1.0
    first_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    evidence_count INTEGER DEFAULT 1,
    metadata JSONB DEFAULT '{}',

    CONSTRAINT valid_relationship_type CHECK (relationship_type IN ('WORKS_WITH', 'MET_AT', 'DISCUSSED', 'REPORTS_TO', 'KNOWS', 'COLLABORATED')),
    CONSTRAINT no_self_relationship CHECK (source_entity_id != target_entity_id)
);

CREATE INDEX IF NOT EXISTS idx_relationships_user ON relationships(user_id);
CREATE INDEX IF NOT EXISTS idx_relationships_source ON relationships(source_entity_id);
CREATE INDEX IF NOT EXISTS idx_relationships_target ON relationships(target_entity_id);

-- Decisions extracted from memories
CREATE TABLE IF NOT EXISTS decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    memory_id UUID NOT NULL REFERENCES memories(id),
    decision_text TEXT NOT NULL,
    deciders TEXT[] DEFAULT '{}',  -- Array of person names
    context TEXT,
    confidence DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'ACTIVE',  -- ACTIVE, REVERTED, SUPERSEDED
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}',

    CONSTRAINT valid_decision_status CHECK (status IN ('ACTIVE', 'REVERTED', 'SUPERSEDED', 'PENDING'))
);

CREATE INDEX IF NOT EXISTS idx_decisions_user_id ON decisions(user_id);
CREATE INDEX IF NOT EXISTS idx_decisions_memory ON decisions(memory_id);
CREATE INDEX IF NOT EXISTS idx_decisions_status ON decisions(status);

-- Actions extracted from memories (todo items, deadlines)
CREATE TABLE IF NOT EXISTS actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    memory_id UUID NOT NULL REFERENCES memories(id),
    action_text TEXT NOT NULL,
    owner VARCHAR(255),  -- Person responsible
    deadline TIMESTAMP,
    status VARCHAR(50) DEFAULT 'PENDING',  -- PENDING, IN_PROGRESS, DONE, BLOCKED, CANCELLED
    priority VARCHAR(50) DEFAULT 'MEDIUM',  -- LOW, MEDIUM, HIGH, URGENT
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',

    CONSTRAINT valid_action_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'DONE', 'BLOCKED', 'CANCELLED')),
    CONSTRAINT valid_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT'))
);

CREATE INDEX IF NOT EXISTS idx_actions_user_id ON actions(user_id);
CREATE INDEX IF NOT EXISTS idx_actions_status ON actions(status);
CREATE INDEX IF NOT EXISTS idx_actions_deadline ON actions(deadline);
CREATE INDEX IF NOT EXISTS idx_actions_owner ON actions(owner);

-- User preferences and settings
CREATE TABLE IF NOT EXISTS user_settings (
    user_id VARCHAR(255) PRIMARY KEY,
    morning_brief_time TIME DEFAULT '08:30',
    end_of_day_time TIME DEFAULT '18:00',
    serendipity_day VARCHAR(10) DEFAULT 'FRIDAY',  -- Day of week
    capture_sources TEXT[] DEFAULT '{"CALENDAR", "SLACK", "EMAIL"}',
    retention_days INTEGER DEFAULT 365,
    privacy_level VARCHAR(50) DEFAULT 'BALANCED',  -- MINIMAL, BALANCED, COMPLETE
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Capture log (audit trail of what was ingested)
CREATE TABLE IF NOT EXISTS capture_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    source VARCHAR(50) NOT NULL,
    source_id VARCHAR(255),  -- External ID (e.g., Slack message ID)
    raw_content_hash VARCHAR(64) NOT NULL,  -- SHA-256 of raw content
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,  -- SUCCESS, FAILED, FILTERED, ENCRYPTED
    error_message TEXT,
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_capture_log_user ON capture_log(user_id);
CREATE INDEX IF NOT EXISTS idx_capture_log_source ON capture_log(source);
CREATE INDEX IF NOT EXISTS idx_capture_log_time ON capture_log(processed_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER update_memories_updated_at BEFORE UPDATE ON memories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_entities_updated_at BEFORE UPDATE ON entities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();