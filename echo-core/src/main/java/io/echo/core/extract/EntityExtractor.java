package io.echo.core.extract;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.V;
import dev.langchain4j.service.spring.AiService;

import java.util.List;

/**
 * EntityExtractor uses LangChain4j AiServices to extract structured entities
 * from raw text (calendar events, Slack messages, emails, etc.)
 * 
 * Runs against local Ollama (Llama 3.1 8B) for privacy.
 * Falls back to Groq API for speed if local model is slow.
 */
@AiService
public interface EntityExtractor {

    @SystemMessage("You are a precise entity extraction system. Extract all mentioned entities from the text. Rules: Only extract entities explicitly mentioned in the text. Normalize names (remove titles like Dr., Mr., etc.). Infer email domains from organizations when possible. Do not hallucinate entities not in the text. Return empty lists if no entities of a type are found. Entity types: PERSON, ORGANIZATION, PROJECT, LOCATION, TOPIC.")
    @UserMessage("Extract entities from: {{text}}")
    ExtractedEntities extract(@V("text") String text);

    record ExtractedEntities(
        List<Person> people,
        List<Organization> organizations,
        List<Project> projects,
        List<Location> locations,
        List<Topic> topics
    ) {}

    record Person(String name, String role, String email, double confidence) {}
    record Organization(String name, String type, String domain, double confidence) {}
    record Project(String name, String description, String status, double confidence) {}
    record Location(String name, String type, double confidence) {}
    record Topic(String name, String category, double confidence) {}
}