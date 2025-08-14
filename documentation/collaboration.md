# Collaboration System Documentation

## Overview
The collaboration system allows wedding couples to invite family and friends to help with wedding planning, and real-time synchronization.

## User Flow

### 1. Invitation Process
**Entry Point**: Collaboration screen → "Neue Einladung senden"
**Steps**:
1. Enter collaborator's email address
4. Send invitation via email
5. Track invitation status

### 2. Invitation Acceptance
**Collaborator Experience**:
1. Receives email invitation
2. Clicks invitation link
3. Creates account or logs in
4. Accepts/declines invitation
5. Gains access to shared planning data

### 3. Permission Management
**Owner Controls**:
- Grant/revoke access to specific modules
- Remove collaborators

## Technical Implementation

### File Structure
```
lib/pages/collaboration_screen.dart
├── CollaborationScreen (StatefulWidget)
├── _CollaborationScreenState
├── _sendInvitation()
├── _acceptInvitation()
├── _revokeAccess()
└── _loadCollaborators()

lib/services/collaboration_service.dart
├── CollaborationService
├── sendInvitationEmail()
├── processInvitationResponse()
└── syncCollaboratorData()
```

### Key Methods

#### sendInvitation()
```dart
Future<void> sendInvitation({
  required String email,
  required List<String> modules,
  String? message,
}) async {
  // Validate email and permissions
  // Create invitation document
  // Send email via EmailService
  // Track invitation status
}
```

#### checkPermissions()
```dart
bool hasPermission(String userId, String module, String action) {
  // Check if user is owner
  // Verify collaborator permissions
  // Return access decision
}
```

## Database Schema

### Invitations Collection
**Path**: `/users/{ownerId}/invitations/{invitationId}`
```json
{
  "id": "invitation-123",
  "inviterId": "owner-user-id",
  "inviterName": "Max Mustermann",
  "inviteeEmail": "collaborator@example.com",
  "inviteeId": null,
  "status": "pending",
  },
  "message": "Hilf mir bei der Hochzeitsplanung!",
  "invitationToken": "secure-random-token",
  "createdAt": "2024-01-01T00:00:00Z",
  "sentAt": "2024-01-01T00:00:00Z",
  "respondedAt": null,
  "acceptedAt": null,
  "expiresAt": "2024-02-01T00:00:00Z"
}
```

### Collaborations Collection
**Path**: `/users/{ownerId}/collaborations/{collaborationId}`
```json
{
  "id": "collaboration-123",
  "ownerId": "owner-user-id",
  "collaboratorId": "collaborator-user-id",
  "collaboratorEmail": "collaborator@example.com",
  "collaboratorName": "Anna Schmidt",

  },
  "status": "active",
  "role": "collaborator",
  "invitedAt": "2024-01-01T00:00:00Z",
  "acceptedAt": "2024-01-02T10:00:00Z",
  "lastActiveAt": "2024-01-15T10:00:00Z",
  "activityCount": 25,
  "notes": "Hilft bei Gästeliste und Tischplanung"
}
```

## Email Integration

### Email Service Integration
```dart
Future<void> sendCollaborationInvite({
  required String email,
  required String inviterName,
  required List<String> modules,
  required String invitationToken,
  String? message,
}) async {
  final emailData = {
    'to': email,
    'subject': 'Einladung zur Hochzeitsplanung von $inviterName',
    'templateType': 'collaboration_invite',
    'templateData': {
      'inviterName': inviterName,
      'modules': modules,
      'message': message ?? '',
      'acceptUrl': 'https://app.4secrets.de/invite/accept/$invitationToken',
      'declineUrl': 'https://app.4secrets.de/invite/decline/$invitationToken',
    }
  };
  
  await EmailService.sendEmail(emailData);
}
```

## Real-time Synchronization

### Firestore Listeners
```dart
class CollaborationSync {
  StreamSubscription? _collaborationListener;
  
  void startListening(String userId) {
    _collaborationListener = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('collaborations')
        .snapshots()
        .listen((snapshot) {
          _handleCollaborationChanges(snapshot);
        });
  }
  
  void _handleCollaborationChanges(QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          _handleNewCollaborator(change.doc);
          break;
        case DocumentChangeType.modified:
          _handleUpdatedCollaborator(change.doc);
          break;
        case DocumentChangeType.removed:
          _handleRemovedCollaborator(change.doc);
          break;
      }
    }
  }
}
```

### Conflict Resolution
```dart
class ConflictResolver {
  static Map<String, dynamic> resolveConflict(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
  ) {
    // Last-write-wins strategy
    final localTimestamp = localData['updatedAt'] as Timestamp;
    final remoteTimestamp = remoteData['updatedAt'] as Timestamp;
    
    return localTimestamp.compareTo(remoteTimestamp) > 0 
        ? localData 
        : remoteData;
  }
}
```

## Activity Tracking

### Activity Log Schema
```json
{
  "id": "activity-123",
  "userId": "user-who-made-change",
  "userName": "Anna Schmidt",
  "action": "guest_added",
  "module": "guests",
  "resourceId": "guest-456",
  "resourceName": "Max Mustermann",
  "details": {
    "previousValue": null,
    "newValue": {
      "name": "Max Mustermann",
      "email": "max@example.com"
    }
  },
  "timestamp": "2024-01-15T10:00:00Z",
  "ipAddress": "192.168.1.1",
  "userAgent": "Mozilla/5.0..."
}
```

### Activity Types
```dart
enum ActivityType {
  // Guest management
  guestAdded,
  guestUpdated,
  guestDeleted,
  guestRsvpChanged,
  
  // Table management
  tableCreated,
  tableUpdated,
  tableDeleted,
  guestAssigned,
  guestUnassigned,
  
  // Timeline management
  timeSlotAdded,
  timeSlotUpdated,
  timeSlotDeleted,
  
  // Collaboration
  collaboratorInvited,
  collaboratorAccepted,
  collaboratorRemoved,

z}
```

