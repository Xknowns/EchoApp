package io.echo.integrations.calendar;

import io.echo.core.capture.EventRouter;
import io.echo.core.capture.EventSource;
import org.springframework.stereotype.Component;

/**
 * Google Calendar Integration - Passive capture
 */
@Component
public class GoogleCalendarAdapter {

    private final EventRouter eventRouter;

    public GoogleCalendarAdapter(EventRouter eventRouter) {
        this.eventRouter = eventRouter;
    }

    public void onNewEvent(String title, String description, String startTime, String userId) {
        String content = "Calendar Event: " + title + ". " + description;
        eventRouter.processEvent(content, EventSource.CALENDAR, userId);
        System.out.println("📅 Google Calendar event captured");
    }
}