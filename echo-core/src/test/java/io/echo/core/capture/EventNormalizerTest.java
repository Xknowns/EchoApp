package io.echo.core.capture;

import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;

class EventNormalizerTest {

    private final EventNormalizer normalizer = new EventNormalizer();

    @Test
    void testNormalization() {
        RawEvent event = normalizer.normalize(
            "Meeting with Sarah about Kafka pricing. We decided to use PostgreSQL.", 
            EventSource.MANUAL, 
            "user-123"
        );

        assertThat(event.rawContent()).contains("Kafka pricing");
        assertThat(event.source()).isEqualTo(EventSource.MANUAL);
        assertThat(event.userId()).isEqualTo("user-123");
        assertThat(event.canonicalHash()).isNotBlank();
    }

    @Test
    void testCalendarNormalization() {
        RawEvent event = normalizer.normalizeCalendarEvent(
            "Team Sync", 
            "Discuss Q3 goals", 
            "2026-06-04T10:00:00Z", 
            "user-123"
        );

        assertThat(event.rawContent()).contains("Team Sync");
        assertThat(event.source()).isEqualTo(EventSource.CALENDAR);
    }
}