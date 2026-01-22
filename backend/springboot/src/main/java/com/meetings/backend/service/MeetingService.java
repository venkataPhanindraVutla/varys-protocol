package com.meetings.backend.service;

import com.meetings.backend.model.Meeting;
import com.meetings.backend.repository.MeetingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Business logic for meeting processing.
 * Orchestrates audio storage, AI processing, and database operations.
 */
@Service
public class MeetingService {

    @Autowired
    private MeetingRepository meetingRepository;

    @Autowired
    private AiClientService aiClientService;

    private static final String UPLOAD_DIR = "uploads/audio/";

    /**
     * Process uploaded audio: save, transcribe, summarize, and store in MongoDB.
     */
    public Meeting processAudioMeeting(MultipartFile audioFile) throws IOException {
        // 1. Save audio file
        String audioPath = saveAudioFile(audioFile);

        // 2. Create meeting record
        Meeting meeting = new Meeting();
        meeting.setAudioPath(audioPath);
        meeting = meetingRepository.save(meeting);

        try {
            // 3. Transcribe audio
            String transcription = aiClientService.transcribeAudio(audioFile);
            meeting.setTranscription(transcription);
            meeting = meetingRepository.save(meeting);

            // 4. Summarize transcription
            Map<String, Object> summaryData = aiClientService.summarizeText(transcription);
            meeting.setSummary((String) summaryData.get("summary"));
            meeting.setActionItems((List<String>) summaryData.get("action_items"));
            meeting = meetingRepository.save(meeting);

        } catch (Exception e) {
            // If AI processing fails, meeting still exists with audio path
            throw new RuntimeException("AI processing failed: " + e.getMessage(), e);
        }

        return meeting;
    }

    /**
     * Get meeting by ID.
     */
    public Optional<Meeting> getMeetingById(String id) {
        return meetingRepository.findById(id);
    }

    /**
     * Get all meetings.
     */
    public List<Meeting> getAllMeetings() {
        return meetingRepository.findAll();
    }

    /**
     * Delete meeting by ID.
     */
    public void deleteMeeting(String id) {
        meetingRepository.deleteById(id);
    }

    /**
     * Save audio file to local storage.
     */
    private String saveAudioFile(MultipartFile file) throws IOException {
        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Generate unique filename
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : ".wav";
        String filename = UUID.randomUUID().toString() + extension;

        // Save file
        Path filePath = uploadPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        return filePath.toString();
    }
}
