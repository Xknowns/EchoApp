package io.echo.core.capture;

/**
 * Event sources supported by ECHO.
 * Used for canonicalization and audit trail integrity (TGP compatible).
 */
public enum EventSource {

    CALENDAR,
    SLACK,
    EMAIL,
    BROWSER,
    MANUAL,
    VOICE,
    PHOTO,
    UNKNOWN;

    /**
     * Parse source string to enum with fallback
     */
    public static EventSource fromString(String source) {
        if (source == null) {
            return UNKNOWN;
        }
        try {
            return EventSource.valueOf(source.toUpperCase().trim());
        } catch (IllegalArgumentException e) {
            return UNKNOWN;
        }
    }
}