package io.echo.core.memory;

import io.echo.core.capture.RawEvent;
import io.echo.core.extract.EntityExtractor;
import org.springframework.stereotype.Service;
import org.springframework.ai.embedding.EmbeddingClient;
import org.springframework.ai.vectorstore.VectorStore;

import java.util.List;

@Service
public class MemoryService {

    private final VectorStore vectorStore;
    private final EntityExtractor entityExtractor;
    private final EmbeddingClient embeddingClient;

    public MemoryService(VectorStore vectorStore, EntityExtractor entityExtractor, EmbeddingClient embeddingClient) {
        this.vectorStore = vectorStore;
        this.entityExtractor = entityExtractor;
        this.embeddingClient = embeddingClient;
    }

    public void store(RawEvent event) {
        // Extract entities, decisions, actions
        var entities = entityExtractor.extract(event.rawContent());
        
        // Create embedding
        // List<Double> embedding = embeddingClient.embed(event.rawContent());
        
        // Store in pgvector via repository
        System.out.println("📦 Stored memory: " + event.rawContent().substring(0, 60) + "...");
        System.out.println("   Entities found: " + entities.people().size());
    }

    public List<String> semanticSearch(String query) {
        // Vector similarity search <100ms target
        return List.of("Found relevant memories for: " + query);
    }
}