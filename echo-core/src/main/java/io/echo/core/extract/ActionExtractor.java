package io.echo.core.extract;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.V;
import dev.langchain4j.service.spring.AiService;

import java.time.LocalDate;
import java.util.List;

/**
 * ActionExtractor identifies action items, deadlines, and blockers
 * from conversations and documents.
 */
@AiService
public interface ActionExtractor {

    @SystemMessage("You are an action item extraction system. Identify tasks, deadlines, and blockers. Action indicators: I will, I'll handle, You need to, By Friday, Follow up on. Blocker indicators: Blocked by, Waiting for, Need approval, Can't proceed until. For each action extract: what needs to be done, who is responsible, when it's due, whether blocked, priority inferred from urgency language.")
    @UserMessage("Extract actions from: {{text}}")
    ExtractedActions extract(@V("text") String text);

    record ExtractedActions(List<Action> actions, List<Blocker> blockers, int totalActions, int totalBlockers) {}

    record Action(
        String actionText,
        String owner,
        String deadlineText,
        LocalDate inferredDeadline,
        Priority priority,
        boolean isBlocked,
        String blockerReason,
        double confidence
    ) {}

    record Blocker(String blockedItem, String blockerDescription, String waitingOn, String resolutionNeeded) {}

    enum Priority { LOW, MEDIUM, HIGH, URGENT }
}