# Tischverwaltung (Table Management) Documentation

## Overview
The Tischverwaltung feature enables couples to manage guest seating arrangements, create tables, assign guests, and visualize the reception layout.

## User Flow

### 1. Initial Access
- **Entry Point**: Main dashboard → "Tischverwaltung" card
- **Authentication**: Requires logged-in user
- **Navigation**: `lib/pages/tischverwaltung.dart`

### 2. Main Interface
```
┌─────────────────────────────────────┐
│ Tischverwaltung                     │
│ [+ Neuen Tisch hinzufügen]          │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Tisch 1 - Brautpaar            │ │
│ │ 👥 8 Plätze (6 belegt)          │ │
│ │ • Max Mustermann               │ │
│ │ • Anna Schmidt                 │ │
│ │ • ...                          │ │
│ │ [Bearbeiten] [Löschen]         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Tisch 2 - Familie              │ │
│ │ 👥 10 Plätze (4 belegt)         │ │
│ │ [Bearbeiten] [Löschen]         │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 3. Adding New Table
**Trigger**: Tap "+ Neuen Tisch hinzufügen" button
**Modal Fields**:
- **Tischname (Table Name)**: Text input (required)
- **Anzahl Plätze (Seat Count)**: Number input (required, 2-20)
- **Beschreibung (Description)**: Text area (optional)
- **Tischform (Table Shape)**: Dropdown (Rund/Rechteckig/Oval)

**Validation Rules**:
- Table name is required (1-50 characters)
- Seat count must be between 2-20
- Table name must be unique
- Description max 200 characters

### 4. Managing Table Guests
**Trigger**: Tap "Bearbeiten" on table card
**Guest Assignment Interface**:
- **Available Guests**: List of unassigned guests
- **Assigned Guests**: Current table occupants
- **Drag & Drop**: Move guests between tables
- **Search**: Find specific guests
- **Filters**: Filter by guest categories

### 5. Guest Management Integration
**Connection**: Links with guest list from other modules
**Guest Sources**:
- Manual guest entries
- Imported guest lists
- Collaboration additions
- RSVP responses

## Technical Implementation

### File Structure
```
lib/pages/tischverwaltung.dart
├── TischverwaltungPage (StatefulWidget)
├── _TischverwaltungPageState
├── _buildTableCard()
├── _showAddTableDialog()
├── _showEditTableDialog()
├── _addTable()
├── _editTable()
├── _deleteTable()
├── _loadTables()
├── _loadGuests()
├── _assignGuestToTable()
└── _removeGuestFromTable()

lib/widgets/table_management/
├── table_card.dart
├── guest_assignment_dialog.dart
├── table_layout_view.dart
└── guest_search_widget.dart
```

### Key Methods

#### _loadTables()
```dart
Future<void> _loadTables() async {
  // Fetches all tables from Firestore
  // Loads assigned guests for each table
  // Updates UI state with table data
}
```

#### _addTable()
```dart
Future<void> _addTable(Map<String, dynamic> tableData) async {
  // Validates table data
  // Checks for duplicate names
  // Creates new table document
  // Refreshes table list
}
```

#### _assignGuestToTable()
```dart
Future<void> _assignGuestToTable(String guestId, String tableId) async {
  // Validates seat availability
  // Updates guest document with table assignment
  // Updates table occupancy count
  // Syncs changes across devices
}
```

## Database Schema

### Collection: `tables`
**Path**: `/users/{userId}/tables/{tableId}`

#### Table Document Structure
```json
{
  "id": "auto-generated-id",
  "userId": "firebase-user-id",
  "name": "Tisch 1 - Brautpaar",
  "seatCount": 8,
  "description": "Haupttisch für Brautpaar und engste Familie",
  "shape": "round",
  "position": {
    "x": 100,
    "y": 150
  },
  "assignedGuests": [
    {
      "guestId": "guest-id-1",
      "guestName": "Max Mustermann",
      "seatNumber": 1,
      "specialRequests": "Vegetarisch"
    }
  ],
  "occupiedSeats": 6,
  "availableSeats": 2,
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

#### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| id | String | Yes | Auto-generated | Unique table identifier |
| userId | String | Yes | Firebase UID | Owner user ID |
| name | String | Yes | 1-50 chars, unique | Table display name |
| seatCount | Number | Yes | 2-20 | Total number of seats |
| description | String | No | 0-200 chars | Optional description |
| shape | String | No | round/rectangular/oval | Table shape |
| position | Object | No | x,y coordinates | Layout position |
| assignedGuests | Array | No | Guest objects | List of assigned guests |
| occupiedSeats | Number | Yes | 0-seatCount | Current occupancy |
| availableSeats | Number | Yes | Calculated | Remaining seats |

### Collection: `guests`
**Path**: `/users/{userId}/guests/{guestId}`

#### Guest Document Structure
```json
{
  "id": "auto-generated-id",
  "userId": "firebase-user-id",
  "name": "Max Mustermann",
  "email": "max@example.com",
  "phone": "+49123456789",
  "category": "Familie",
  "rsvpStatus": "confirmed",
  "tableAssignment": {
    "tableId": "table-id-1",
    "tableName": "Tisch 1 - Brautpaar",
    "seatNumber": 1
  },
  "dietaryRequirements": ["vegetarisch"],
  "specialRequests": "Rollstuhlgerecht",
  "plusOne": {
    "name": "Anna Mustermann",
    "tableId": "table-id-1",
    "seatNumber": 2
  },
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

## Validation Rules

### Table Validation
- **Name Uniqueness**: No duplicate table names
- **Seat Count**: Must be between 2-20
- **Name Length**: 1-50 characters
- **Description**: Optional, max 200 characters
- **Shape**: Must be valid option (round/rectangular/oval)

### Guest Assignment Validation
- **Seat Availability**: Cannot exceed table capacity
- **Duplicate Assignment**: Guest cannot be at multiple tables
- **RSVP Status**: Only confirmed guests can be assigned
- **Plus One Handling**: Plus ones must be seated together

### Business Logic Validation
```dart
bool canAssignGuestToTable(String guestId, String tableId) {
  // Check if table has available seats
  // Verify guest is not already assigned
  // Confirm guest RSVP status
  // Validate plus one requirements
  return isValid;
}
```

## UI Components

### Table Card Components
- **Table Header**: Name and seat summary
- **Guest List**: Scrollable list of assigned guests
- **Action Buttons**: Edit and delete options
- **Progress Indicator**: Visual seat occupancy
- **Status Badge**: Full/Available/Empty indicators

### Guest Assignment Dialog
- **Search Bar**: Find guests by name
- **Filter Tabs**: Category-based filtering
- **Available Guests**: Drag source list
- **Assigned Guests**: Drop target list
- **Seat Numbers**: Visual seat arrangement
- **Save/Cancel**: Action buttons

### Table Layout View
- **Visual Layout**: Drag-and-drop table positioning
- **Zoom Controls**: Scale layout view
- **Grid Snap**: Align tables to grid
- **Export Options**: Save layout as image

## Error Handling

### Common Error Scenarios
1. **Table Full**: "Tisch ist bereits voll belegt"
2. **Duplicate Name**: "Tischname bereits vergeben"
3. **Guest Already Assigned**: "Gast ist bereits einem Tisch zugewiesen"
4. **Invalid Seat Count**: "Anzahl Plätze muss zwischen 2 und 20 liegen"
5. **Network Error**: "Verbindungsfehler beim Speichern"

### Validation Feedback
- **Real-time Validation**: Immediate field validation
- **Error Highlighting**: Red borders for invalid fields
- **Success Feedback**: Green checkmarks for valid data
- **Toast Messages**: Quick status updates

## Advanced Features

### Automatic Seating Suggestions
```dart
List<Map<String, dynamic>> suggestSeating() {
  // Analyze guest relationships
  // Consider dietary requirements
  // Balance table sizes
  // Suggest optimal arrangements
}
```

### Conflict Resolution
- **Overbooked Tables**: Highlight capacity issues
- **Unassigned Guests**: Show guests without tables
- **Missing RSVPs**: Identify pending responses
- **Dietary Conflicts**: Flag special requirements

### Export and Printing
- **Seating Chart PDF**: Generate printable charts
- **Table Cards**: Individual table assignments
- **Guest Lists**: Per-table guest lists
- **Layout Diagrams**: Visual room layouts

## Integration Points

### Guest List Integration
- **Bidirectional Sync**: Changes update both modules
- **RSVP Updates**: Automatic table adjustments
- **Category Filtering**: Group guests by relationship
- **Contact Information**: Access guest details

### Catering Integration
- **Dietary Requirements**: Pass special needs to caterer
- **Meal Counts**: Calculate per-table requirements
- **Service Planning**: Optimize serving routes
- **Allergy Alerts**: Highlight critical allergies

### Timeline Integration
- **Seating Deadlines**: Link to wedding timeline
- **Final Count**: Coordinate with catering deadlines
- **Layout Setup**: Schedule table arrangement time
- **Card Printing**: Plan escort card timeline

## Collaboration Features
- **Shared Editing**: Multiple users can assign guests
- **Change Tracking**: Log who made modifications
- **Comments**: Add notes to table assignments
- **Approval Workflow**: Require approval for changes
- **Real-time Updates**: Live synchronization
