package io.echo.core.extract;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.V;
import dev.langchain4j.service.spring.AiService;

import java.time.Instant;
import java.util.List;

/**
 * DecisionDetector identifies decisions, agreements, and resolutions
 * in text conversations and documents.
 * 
 * Key phrases: "we agreed to...", "let's do...", "decided that...",
 * "resolved to...", "concluded that...", "settled on...", "moving forward with..."
 */
@AiService
public interface DecisionDetector {

    @SystemMessage("You are a decision detection system. Identify explicit and implicit decisions in text. A decision is present when people agree on a course of action, a choice is made between alternatives, commitment to future action is made, or policy/direction is set. Do NOT flag suggestions without agreement, hypotheticals, or questions. For each decision extract: what was decided, who decided, confidence 0.0-1.0, whether reversible, any deadlines or conditions.")
    @UserMessage("Detect decisions in: {{text}}")
    DetectedDecisions detect(@V("text") String text);

    record DetectedDecisions(List<Decision> decisions, int totalDecisions, boolean hasExplicitAgreement) {}

    record Decision(
        String decisionText,
        List<String> deciders,
        String context,
        double confidence,
        boolean isReversible,
        String deadline,
        List<String> conditions,
        Instant detectedAt
    ) {}
}