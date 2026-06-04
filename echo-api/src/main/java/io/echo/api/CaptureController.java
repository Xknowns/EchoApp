package io.echo.api;

import io.echo.core.capture.EventNormalizer;
import io.echo.core.capture.EventSource;
import io.echo.core.capture.RawEvent;
import io.echo.core.extract.EntityExtractor;
import io.echo.core.extract.ActionExtractor;
import io.echo.core.extract.DecisionDetector;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class CaptureController {

    private final EventNormalizer normalizer;
    private final EntityExtractor entityExtractor;
    private final DecisionDetector decisionDetector;
    private final ActionExtractor actionExtractor;

    public CaptureController(EventNormalizer normalizer,
                             EntityExtractor entityExtractor,
                             DecisionDetector decisionDetector,
                             ActionExtractor actionExtractor) {
        this.normalizer = normalizer;
        this.entityExtractor = entityExtractor;
        this.decisionDetector = decisionDetector;
        this.actionExtractor = actionExtractor;
    }

    @PostMapping("/capture")
    public String capture(@RequestBody CaptureRequest request) {
        RawEvent event = normalizer.normalize(request.content(), EventSource.valueOf(request.source().toUpperCase()), request.userId());
        
        // Run extraction pipeline
        var entities = entityExtractor.extract(event.rawContent());
        var decisions = decisionDetector.detect(event.rawContent());
        var actions = actionExtractor.extract(event.rawContent());

        // TODO: Store in MemoryService with embeddings

        return "✅ Captured & Processed: " + 
               entities.people().size() + " people, " + 
               decisions.decisions().size() + " decisions, " + 
               actions.actions().size() + " actions";
    }

    record CaptureRequest(String content, String source, String userId) {}
}