# ECHO — Build Instructions

## Phase 1: Core Memory Engine (Completed)

### 1.1 Setup Repository - DONE
### 1.2 Event Capture Layer - DONE
### 1.3 Extraction Pipeline - DONE (Entity, Decision, Action extractors)
### 1.4 Memory Storage - In Progress

## Critical Requirements
- Local-first: Ollama + pgvector
- Privacy: No raw data leaves device
- Speed: Extraction <500ms, Search <100ms
- Quality: mvn clean verify must pass

## Next Priority
Complete echo-core with:
- RawEvent.java
- EventNormalizer.java
- MemoryRepository.java
- CaptureService.java

The unpopular truth: People don't need more tools. They need a system that captures for them.