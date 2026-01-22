package com.meetings.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * HTTP client for communicating with FastAPI AI service.
 * Handles transcription and summarization requests.
 */
@Service
public class AiClientService {

    private final WebClient webClient;

    public AiClientService(@Value("${ai.service.url}") String aiServiceUrl) {
        this.webClient = WebClient.builder()
                .baseUrl(aiServiceUrl)
                .build();
    }

    /**
     * Transcribe audio file using Whisper model.
     */
    public String transcribeAudio(MultipartFile audioFile) throws IOException {
        // Convert MultipartFile to File for WebClient
        File tempFile = convertMultipartFileToFile(audioFile);

        try {
            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("audio", new FileSystemResource(tempFile));

            Map<String, Object> response = webClient.post()
                    .uri("/api/ai/v1/transcribe")
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .bodyValue(body)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();

            return response != null ? (String) response.get("transcription") : "";
        } finally {
            // Clean up temp file
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    /**
     * Summarize transcription text using LLM.
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> summarizeText(String transcription) {
        Map<String, String> requestBody = Map.of("text", transcription);

        Map<String, Object> response = webClient.post()
                .uri("/api/ai/v1/summarize")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        return response;
    }

    private File convertMultipartFileToFile(MultipartFile multipartFile) throws IOException {
        File file = File.createTempFile("upload-", multipartFile.getOriginalFilename());
        try (FileOutputStream fos = new FileOutputStream(file)) {
            fos.write(multipartFile.getBytes());
        }
        return file;
    }
}
