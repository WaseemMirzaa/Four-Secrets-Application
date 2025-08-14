# Database Schema Documentation

## Overview
This document outlines the Firestore database structure for the 4secrets Wedding Planner application.

## Database Architecture

### Root Collections
```
/users/{userId}
├── /tagesablauf/{timeSlotId}
├── /hochzeitskit_progress/{categoryId}
├── /tables/{tableId}
├── /guests/{guestId}
├── /service_providers/{providerId}
├── /collaborations/{collaborationId}
├── /invitations/{invitationId}
├── /todos/{todoId}
├── /budget/{budgetItemId}
└── /settings/{settingId}
```

## Collection Schemas

### 1. Users Collection
**Path**: `/users/{userId}`
```json
{
  "uid": "firebase-auth-uid",
  "email": "user@example.com",
  "displayName": "Max Mustermann",
  "photoURL": "https://...",
  "weddingDate": "2024-06-15",
  "partnerName": "Anna Schmidt",
  "weddingLocation": "München",
  "planningStartDate": "2024-01-01",
  "preferences": {
    "language": "de",
    "currency": "EUR",
    "timezone": "Europe/Berlin",
    "notifications": true
  },
  "subscription": {
    "plan": "premium",
    "expiresAt": "2024-12-31T23:59:59Z",
    "features": ["collaboration", "unlimited_guests"]
  },
  "createdAt": "2024-01-01T00:00:00Z",
  "lastLoginAt": "2024-01-15T10:00:00Z"
}
```

### 2. Tagesablauf Collection
**Path**: `/users/{userId}/tagesablauf/{timeSlotId}`
```json
{
  "id": "timeslot-123",
  "time": "10:00",
  "activity": "Ankunft Braut",
  "description": "Braut kommt im Hotel an",
  "location": "Hotel Beispiel",
  "duration": 60,
  "priority": "high",
  "assignedTo": ["bride", "maid_of_honor"],
  "reminders": [
    {
      "type": "notification",
      "minutesBefore": 30
    }
  ],
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### 3. Hochzeitskit Progress Collection
**Path**: `/users/{userId}/hochzeitskit_progress/{categoryId}`
```json
{
  "categoryId": "beauty_styling",
  "categoryName": "Beauty & Styling",
  "tasks": [
    {
      "id": "task-1",
      "title": "Brautkleid aussuchen",
      "description": "Verschiedene Kleider anprobieren",
      "completed": true,
      "completedAt": "2024-01-15T10:00:00Z",
      "completedBy": "user-id",
      "notes": "Kleid bei Salon XYZ reserviert",
      "priority": "high",
      "dueDate": "2024-03-01",
      "assignedTo": "bride",
      "estimatedCost": 1500.00,
      "actualCost": 1200.00
    }
  ],
  "progress": 0.75,
  "totalTasks": 12,
  "completedTasks": 9,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### 4. Tables Collection
**Path**: `/users/{userId}/tables/{tableId}`
```json
{
  "id": "table-123",
  "name": "Tisch 1 - Brautpaar",
  "seatCount": 8,
  "shape": "round",
  "description": "Haupttisch für Brautpaar",
  "position": {
    "x": 100,
    "y": 150,
    "rotation": 0
  },
  "assignedGuests": [
    {
      "guestId": "guest-123",
      "seatNumber": 1,
      "specialRequests": "Vegetarisch"
    }
  ],
  "occupiedSeats": 6,
  "tableSettings": {
    "centerpiece": "Rosen",
    "tablecloth": "Weiß",
    "specialArrangement": "Hochzeitstorte"
  },
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### 5. Guests Collection
**Path**: `/users/{userId}/guests/{guestId}`
```json
{
  "id": "guest-123",
  "name": "Max Mustermann",
  "email": "max@example.com",
  "phone": "+49123456789",
  "category": "Familie",
  "relationship": "Bruder",
  "rsvpStatus": "confirmed",
  "rsvpDate": "2024-01-10T10:00:00Z",
  "tableAssignment": {
    "tableId": "table-123",
    "seatNumber": 1
  },
  "dietaryRequirements": ["vegetarisch", "glutenfrei"],
  "allergies": ["Nüsse"],
  "specialRequests": "Rollstuhlgerecht",
  "plusOne": {
    "name": "Anna Mustermann",
    "email": "anna@example.com",
    "dietaryRequirements": []
  },
  "address": {
    "street": "Musterstraße 123",
    "city": "München",
    "postalCode": "80331",
    "country": "Deutschland"
  },
  "invitationSent": true,
  "invitationSentAt": "2024-01-05T10:00:00Z",
  "giftPreferences": ["Geldgeschenk", "Wunschliste"],
  "notes": "Kommt mit dem Auto",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### 6. Service Providers Collection
**Path**: `/users/{userId}/service_providers/{providerId}`
```json
{
  "id": "provider-123",
  "name": "Fotograf Schmidt",
  "category": "Fotografie",
  "contactPerson": "Hans Schmidt",
  "email": "info@fotograf-schmidt.de",
  "phone": "+49123456789",
  "website": "https://www.fotograf-schmidt.de",
  "address": {
    "street": "Musterstraße 123",
    "city": "München",
    "postalCode": "80331"
  },
  "pricing": {
    "totalAmount": 2500.00,
    "currency": "EUR",
    "paidAmount": 500.00,
    "paymentSchedule": [
      {
        "amount": 500.00,
        "dueDate": "2024-02-01",
        "paid": true,
        "paidDate": "2024-01-15"
      }
    ]
  },
  "status": "contract_signed",
  "contractDetails": {
    "contractSigned": true,
    "contractDate": "2024-01-15",
    "deliveryDate": "2024-06-15"
  },
  "documents": [
    {
      "id": "doc-123",
      "name": "Vertrag",
      "type": "contract",
      "url": "gs://bucket/contracts/contract-123.pdf",
      "uploadDate": "2024-01-15T10:00:00Z"
    }
  ],
  "rating": 4.8,
  "reviews": [
    {
      "rating": 5,
      "comment": "Sehr professionell",
      "date": "2024-01-10T10:00:00Z"
    }
  ],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

### 7. Collaborations Collection
**Path**: `/users/{userId}/collaborations/{collaborationId}`
```json
{
  "id": "collab-123",
  "ownerId": "owner-user-id",
  "collaboratorId": "collaborator-user-id",
  "collaboratorEmail": "collaborator@example.com",
  "permissions": {
    "canEdit": true,
    "canDelete": false,
    "canInvite": false,
    "modules": ["tagesablauf", "guests", "tables"]
  },
  "status": "active",
  "invitedAt": "2024-01-01T00:00:00Z",
  "acceptedAt": "2024-01-02T10:00:00Z",
  "lastActiveAt": "2024-01-15T10:00:00Z"
}
```

### 8. Invitations Collection
**Path**: `/users/{userId}/invitations/{invitationId}`
```json
{
  "id": "invitation-123",
  "inviterId": "inviter-user-id",
  "inviterName": "Max Mustermann",
  "inviteeEmail": "collaborator@example.com",
  "inviteeId": "invitee-user-id",
  "status": "pending",
  "permissions": {
    "canEdit": true,
    "modules": ["guests", "tables"]
  },
  "message": "Hilf mir bei der Hochzeitsplanung!",
  "createdAt": "2024-01-01T00:00:00Z",
  "sentAt": "2024-01-01T00:00:00Z",
  "respondedAt": null,
  "expiresAt": "2024-02-01T00:00:00Z"
}
```


