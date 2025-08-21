# Weekly Recommendations Backend API Specification

This document outlines the backend API endpoints that need to be implemented for the Weekly Recommendations feature in SolidCV.

## API Endpoints

### 1. Get Current Week Recommendations
**GET** `/api/protected/weekly-recommendations/current`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Response:** `200 OK`
```json
{
  "id": 1,
  "userId": 123,
  "weekStartDate": "2025-08-18",
  "weekEndDate": "2025-08-24",
  "courses": [
    {
      "id": 1,
      "title": "Advanced Flutter Development",
      "description": "Master advanced Flutter concepts including state management, custom animations, and performance optimization.",
      "provider": "Flutter Academy",
      "duration": "4 hours",
      "difficulty": "Advanced",
      "category": "Mobile Development",
      "url": "https://example.com/course/1",
      "imageUrl": "https://example.com/images/flutter-course.jpg",
      "isCompleted": false,
      "completedAt": null,
      "iconName": "school"
    }
  ],
  "events": [
    {
      "id": 1,
      "title": "Tech Conference 2025: AI Revolution",
      "description": "Join industry leaders discussing the latest developments in artificial intelligence and machine learning.",
      "organizer": "Tech Events Inc.",
      "date": "March 15, 2025",
      "time": "9:00 AM - 5:00 PM",
      "location": "Convention Center, Tech City",
      "eventType": "Conference",
      "url": "https://example.com/event/1",
      "imageUrl": "https://example.com/images/ai-conference.jpg",
      "isRegistered": false,
      "registeredAt": null,
      "iconName": "event"
    }
  ],
  "createdAt": "2025-08-18T08:00:00Z",
  "updatedAt": "2025-08-18T08:00:00Z"
}
```

### 2. Get Weekly Progress
**GET** `/api/protected/weekly-recommendations/progress`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Response:** `200 OK`
```json
{
  "totalCourses": 5,
  "completedCourses": 2,
  "totalEvents": 2,
  "registeredEvents": 1,
  "overallProgress": 0.43
}
```

### 3. Mark Course as Completed
**POST** `/api/protected/weekly-recommendations/course/complete`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Request Body:**
```json
{
  "courseId": 1
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Course marked as completed successfully"
}
```

**Error Response:** `409 Conflict` (Already completed)
```json
{
  "error": "Course already completed",
  "message": "This course has already been marked as completed"
}
```

### 4. Register for Event
**POST** `/api/protected/weekly-recommendations/event/register`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Request Body:**
```json
{
  "eventId": 1
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Successfully registered for event"
}
```

**Error Response:** `409 Conflict` (Already registered)
```json
{
  "error": "Already registered",
  "message": "You are already registered for this event"
}
```

### 5. Unregister from Event
**DELETE** `/api/protected/weekly-recommendations/event/unregister/{eventId}`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Successfully unregistered from event"
}
```

### 6. Get Recommendation History
**GET** `/api/protected/weekly-recommendations/history?limit={limit}`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Query Parameters:**
- `limit` (optional): Number of weeks to return (default: 10)

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "userId": 123,
    "weekStartDate": "2025-08-18",
    "weekEndDate": "2025-08-24",
    "courses": [...],
    "events": [...],
    "createdAt": "2025-08-18T08:00:00Z",
    "updatedAt": "2025-08-18T08:00:00Z"
  }
]
```

### 7. Get Recommendations for Specific Week
**GET** `/api/protected/weekly-recommendations/week/{weekStartDate}`

**Headers:**
- `Content-Type: application/json`
- `X-Auth-Token: {JWT_TOKEN}`

**Parameters:**
- `weekStartDate`: Date in format YYYY-MM-DD

**Response:** `200 OK`
Same format as endpoint #1

## Database Schema

### Weekly Recommendations Table
```sql
CREATE TABLE weekly_recommendations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, week_start_date)
);
```

### Recommended Courses Table
```sql
CREATE TABLE recommended_courses (
    id SERIAL PRIMARY KEY,
    weekly_recommendation_id INTEGER NOT NULL REFERENCES weekly_recommendations(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    provider VARCHAR(255),
    duration VARCHAR(100),
    difficulty VARCHAR(50),
    category VARCHAR(100),
    url TEXT,
    image_url TEXT,
    icon_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Course Completions Table
```sql
CREATE TABLE course_completions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    course_id INTEGER NOT NULL REFERENCES recommended_courses(id),
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, course_id)
);
```

### Recommended Events Table
```sql
CREATE TABLE recommended_events (
    id SERIAL PRIMARY KEY,
    weekly_recommendation_id INTEGER NOT NULL REFERENCES weekly_recommendations(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    organizer VARCHAR(255),
    event_date VARCHAR(100),
    event_time VARCHAR(100),
    location TEXT,
    event_type VARCHAR(100),
    url TEXT,
    image_url TEXT,
    icon_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Event Registrations Table
```sql
CREATE TABLE event_registrations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    event_id INTEGER NOT NULL REFERENCES recommended_events(id),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, event_id)
);
```

## Business Logic Notes

1. **Weekly Generation**: Recommendations should be generated every Monday for the current week
2. **Personalization**: Consider user's skills, career goals, industry, and past completions
3. **Progression**: Track user progress and adjust future recommendations accordingly
4. **External Integration**: May integrate with external course platforms and event APIs
5. **Analytics**: Track completion rates and user engagement for improving recommendations

## Error Handling

All endpoints should return appropriate HTTP status codes:
- `200 OK`: Success
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Invalid or missing JWT token
- `404 Not Found`: Resource not found
- `409 Conflict`: Duplicate action (already completed/registered)
- `500 Internal Server Error`: Server error

## Authentication

All protected endpoints require a valid JWT token in the `X-Auth-Token` header. The token should contain the user's ID for personalized recommendations.
