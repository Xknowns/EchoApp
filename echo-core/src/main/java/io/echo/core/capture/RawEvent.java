package io.echo.core.capture;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * Immutable unified event schema for all sources.
 * Core of the automatic capture pipeline.
 */
public record RawEvent(
    String id,
    EventSource source,
    String rawContent,
    Instant timestamp,
    Map<String, String> metadata,
    String userId,
    String canonicalHash  // For TGP audit trail integrity
) {

    public static RawEvent create(EventSource source, String rawContent, String userId, Map<String, String> metadata) {
        String id = UUID.randomUUID().toString();
        Instant now = Instant.now();
        return new RawEvent(id, source, rawContent, now, metadata != null ? metadata : Map.of(), userId, 
            org.apache.commons.codec.digest.DigestUtils.sha256Hex(rawContent + userId));
    }
}
