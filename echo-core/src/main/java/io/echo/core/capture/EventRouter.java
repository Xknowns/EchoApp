package io.echo.core.capture;

import io.echo.core.extract.EntityExtractor;
import io.echo.core.extract.DecisionDetector;
import io.echo.core.extract.ActionExtractor;
import io.echo.core.memory.MemoryService;
import org.springframework.stereotype.Component;

/**
 * Orchestrates the full automatic extraction pipeline.
 */
@Component
public class EventRouter {

    private final EventNormalizer normalizer;
    private final EntityExtractor entityExtractor;
    private final DecisionDetector decisionDetector;
    private final ActionExtractor actionExtractor;
    private final MemoryService memoryService;

    public EventRouter(EventNormalizer normalizer, 
                       EntityExtractor entityExtractor,
                       DecisionDetector decisionDetector,
                       ActionExtractor actionExtractor,
                       MemoryService memoryService) {
        this.normalizer = normalizer;
        this.entityExtractor = entityExtractor;
        this.decisionDetector = decisionDetector;
        this.actionExtractor = actionExtractor;
        this.memoryService = memoryService;
    }

    public void processEvent(String rawContent, EventSource source, String userId) {
        RawEvent event = normalizer.normalize(rawContent, source, userId);
        
        // Parallel extraction pipeline
        var entities = entityExtractor.extract(event.rawContent());
        var decisions = decisionDetector.detect(event.rawContent());
        var actions = actionExtractor.extract(event.rawContent());

        // Store everything
        memoryService.store(event);

        System.out.println("🔄 ECHO Processed Event → " + 
            entities.people().size() + " entities, " +
            decisions.decisions().size() + " decisions, " +
            actions.actions().size() + " actions");
    }
}