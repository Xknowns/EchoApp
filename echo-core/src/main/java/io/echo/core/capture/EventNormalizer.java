package io.echo.core.capture;

import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Normalizes different source formats into RawEvent.
 * Ensures consistent canonicalization across platforms.
 */
@Component
public class EventNormalizer {

    public RawEvent normalize(String rawInput, EventSource source, String userId) {
        // Basic normalization - extend with source-specific parsers
        String cleaned = rawInput.trim()
                .replaceAll("\\s+", " ")
                .replaceAll("[^\\p{Print}]", "");

        Map<String, String> metadata = Map.of(
            "normalizedAt", java.time.Instant.now().toString(),
            "sourceVersion", "1.0"
        );

        return RawEvent.create(source, cleaned, userId, metadata);
    }

    public RawEvent normalizeCalendarEvent(String title, String description, String startTime, String userId) {
        String content = "Calendar: " + title + ". " + description;
        Map<String, String> meta = Map.of("startTime", startTime, "type", "calendar");
        return RawEvent.create(EventSource.CALENDAR, content, userId, meta);
    }
}