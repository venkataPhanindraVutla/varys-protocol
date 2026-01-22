package com.meetings.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

/**
 * Main entry point for the AI Meeting Assistant backend.
 * Starts Spring Boot with MongoDB support.
 */
@SpringBootApplication
@EnableMongoRepositories(basePackages = "com.meetings.backend.repository")
public class BackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
    }
}
