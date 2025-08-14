# Tagesablauf (Daily Schedule) Documentation

## Overview
The Tagesablauf feature allows couples to create and manage their wedding day timeline with detailed time slots and activities.

## User Flow

### 1. Initial Access
- **Entry Point**: Main dashboard → "Tagesablauf" card
- **Authentication**: Requires logged-in user
- **Navigation**: `lib/pages/tagesablauf.dart`

### 2. Main Interface
```
┌─────────────────────────────────────┐
│ Tagesablauf für [Date]              │
│ ┌─────────────────────────────────┐ │
│ │ + Neuen Zeitslot hinzufügen     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 10:00 - Ankunft Braut          │ │
│ │ 📝 Beschreibung...              │ │
│ │ [Bearbeiten] [Löschen]          │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 3. Adding New Time Slot
**Trigger**: Tap "Neuen Zeitslot hinzufügen" button
**Modal Fields**:
- **Zeit (Time)**: Time picker (HH:MM format)
- **Aktivität (Activity)**: Text input (required, max 100 chars)
- **Beschreibung (Description)**: Text area (optional, max 500 chars)
- **Ort (Location)**: Text input (optional, max 200 chars)

**Validation Rules**:
- Time cannot be empty
- Activity name is required
- Time must be in valid format (00:00 - 23:59)

### 4. Editing Time Slot
**Trigger**: Tap "Bearbeiten" on existing slot
**Behavior**: Opens same modal with pre-filled data
**Changes**: Updates existing document in Firestore

### 5. Deleting Time Slot
**Trigger**: Tap "Löschen" button
**Confirmation**: Shows confirmation dialog
**Action**: Removes document from Firestore collection

## Technical Implementation

### File Structure
```
lib/pages/tagesablauf.dart
├── TagesablaufPage (StatefulWidget)
├── _TagesablaufPageState
├── _buildTimeSlotCard()
├── _showAddTimeSlotDialog()
├── _addTimeSlot()
├── _editTimeSlot()
├── _deleteTimeSlot()
└── _loadTimeSlots()
```

### Key Methods

#### _loadTimeSlots()
```dart
Future<void> _loadTimeSlots() async {
  // Fetches time slots from Firestore
  // Orders by time ascending
  // Updates UI state
}
```

#### _addTimeSlot()
```dart
Future<void> _addTimeSlot(Map<String, dynamic> data) async {
  // Validates input data
  // Checks for duplicate times
  // Saves to Firestore
  // Refreshes UI
}
```

#### _showAddTimeSlotDialog()
```dart
void _showAddTimeSlotDialog({Map<String, dynamic>? existingData}) {
  // Shows modal dialog
  // Handles form validation
  // Manages time picker
  // Calls add/edit methods
}
```

## Database Schema

### Collection: `tagesablauf`
**Path**: `/users/{userId}/tagesablauf/{timeSlotId}`

#### Document Structure
```json
{
  "id": "auto-generated-id",
  "userId": "firebase-user-id",
  "time": "10:00",
  "activity": "Ankunft Braut",
  "description": "Braut kommt im Hotel an und beginnt mit den Vorbereitungen",
  "location": "Hotel Beispiel, Zimmer 205",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

#### Field Specifications
| Field | Type | Required | Max Length | Description |
|-------|------|----------|------------|-------------|
| id | String | Yes | - | Auto-generated document ID |
| userId | String | Yes | - | Firebase user ID |
| time | String | Yes | 5 | Time in HH:MM format |
| activity | String | Yes | 100 | Activity name/title |
| description | String | No | 500 | Detailed description |
| location | String | No | 200 | Location/venue information |
| createdAt | Timestamp | Yes | - | Creation timestamp |
| updatedAt | Timestamp | Yes | - | Last update timestamp |

## Validation Rules

### Time Validation
- **Format**: Must be HH:MM (24-hour format)
- **Range**: 00:00 to 23:59
- **Required**: Cannot be empty

### Activity Validation
- **Required**: Must have activity name
- **Length**: 1-100 characters
- **Content**: No special validation, allows all characters

### Description Validation
- **Optional**: Can be empty
- **Length**: 0-500 characters
- **Content**: Supports multiline text

### Location Validation
- **Optional**: Can be empty
- **Length**: 0-200 characters
- **Content**: No special validation

## Error Handling

### Common Error Scenarios
1. **Duplicate Time**: "Diese Zeit ist bereits vergeben"
2. **Invalid Time Format**: "Bitte geben Sie eine gültige Zeit ein"
3. **Empty Activity**: "Aktivität ist erforderlich"

### Error Display
- **Toast Messages**: For quick feedback
- **Dialog Alerts**: For critical errors
- **Inline Validation**: Real-time form validation

## UI Components

### Main Screen Components
- **AppBar**: Title with date
- **FloatingActionButton**: Add new time slot
- **ListView**: Scrollable list of time slots
- **TimeSlotCard**: Individual time slot display

### Modal Dialog Components
- **TimePicker**: Native time selection
- **TextFormField**: Activity input
- **TextFormField**: Description input (multiline)
- **TextFormField**: Location input
- **ElevatedButton**: Save/Update action
- **TextButton**: Cancel action

### Styling
- **Primary Color**: App theme color
- **Card Elevation**: 2.0
- **Border Radius**: 12.0
- **Padding**: 16.0 standard
- **Font Sizes**: Title 18, Body 14, Caption 12

## Collaboration Features
- **Shared Access**: Collaborators can view and edit
- **Real-time Updates**: Changes sync across devices
- **Permission Levels**: Owner and collaborator access
- **Activity Logging**: Track who made changes
