package com.meetings.backend.repository;

import com.meetings.backend.model.Meeting;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * MongoDB repository for Meeting documents.
 * Provides CRUD operations and custom queries.
 */
@Repository
public interface MeetingRepository extends MongoRepository<Meeting, String> {

    // Custom query methods can be added here
    // Example: List<Meeting> findByCreatedAtBetween(LocalDateTime start,
    // LocalDateTime end);
}
