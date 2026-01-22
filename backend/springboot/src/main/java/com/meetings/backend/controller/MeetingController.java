package com.meetings.backend.controller;

import com.meetings.backend.model.Meeting;
import com.meetings.backend.service.MeetingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

/**
 * REST API controller for meeting operations.
 * Base path: /api/backend/v1/meetings
 */
@RestController
@RequestMapping("/api/backend/v1/meetings")
public class MeetingController {

    @Autowired
    private MeetingService meetingService;

    /**
     * Upload and process audio meeting.
     * POST /api/backend/v1/meetings
     */
    @PostMapping
    public ResponseEntity<?> uploadMeeting(@RequestParam("audio") MultipartFile audioFile) {
        try {
            if (audioFile.isEmpty()) {
                return ResponseEntity.badRequest().body("Audio file is required");
            }

            Meeting meeting = meetingService.processAudioMeeting(audioFile);
            return ResponseEntity.status(HttpStatus.CREATED).body(meeting);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error processing meeting: " + e.getMessage());
        }
    }

    /**
     * Get meeting by ID.
     * GET /api/backend/v1/meetings/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getMeeting(@PathVariable String id) {
        Optional<Meeting> meeting = meetingService.getMeetingById(id);

        if (meeting.isPresent()) {
            return ResponseEntity.ok(meeting.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Meeting not found with id: " + id);
        }
    }

    /**
     * Get all meetings.
     * GET /api/backend/v1/meetings
     */
    @GetMapping
    public ResponseEntity<List<Meeting>> getAllMeetings() {
        List<Meeting> meetings = meetingService.getAllMeetings();
        return ResponseEntity.ok(meetings);
    }

    /**
     * Delete meeting by ID.
     * DELETE /api/backend/v1/meetings/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteMeeting(@PathVariable String id) {
        try {
            meetingService.deleteMeeting(id);
            return ResponseEntity.ok("Meeting deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error deleting meeting: " + e.getMessage());
        }
    }
}
