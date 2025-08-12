# Hochzeitskit (Wedding Kit) Documentation

## Overview
The Hochzeitskit feature provides couples with comprehensive wedding planning tools, checklists, and resources organized by categories.

## User Flow

### 1. Initial Access
- **Entry Point**: Main dashboard → "Hochzeitskit" card
- **Authentication**: Requires logged-in user
- **Navigation**: `lib/pages/hochzeitskit.dart`

### 2. Category Selection Interface
```
┌─────────────────────────────────────┐
│ Hochzeitskit                        │
│                                     │
│ ┌─────────────┐ ┌─────────────┐    │
│ │ 💄 Beauty &  │ │ 🎵 Band &    │    │
│ │ Styling     │ │ Musik       │    │
│ │ 12 Aufgaben │ │ 8 Aufgaben  │    │
│ └─────────────┘ └─────────────┘    │
│                                     │
│ ┌─────────────┐ ┌─────────────┐    │
│ │ 🍰 Catering │ │ 📸 Foto &    │    │
│ │ 15 Aufgaben │ │ Video       │    │
│ └─────────────┘ └─────────────┘    │
└─────────────────────────────────────┘
```

### 3. Category Detail View
**Trigger**: Tap on any category card
**Navigation**: Opens category-specific page with swipeable cards
**Content**: Pre-defined tasks and checklists for that category

### 4. Task Management
- **View Tasks**: Swipeable card interface
- **Mark Complete**: Checkbox interaction
- **Add Notes**: Text input for personal notes

## Technical Implementation

### File Structure
```
lib/pages/hochzeitskit.dart
├── HochzeitskitPage (StatefulWidget)
├── _HochzeitskitPageState
├── _buildCategoryCard()
├── _navigateToCategory()
└── _getCategoryProgress()

lib/pages/category_pages/
├── beauty_styling.dart
├── band_musik.dart
├── catering.dart
├── foto_video.dart
├── location.dart
├── blumen_dekoration.dart
├── einladungen.dart
├── bachelorette_party.dart
└── honeymoon.dart
```

### Category Implementation Pattern
Each category follows the same structure:
```dart
class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> tasks = [];
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    // Load tasks from Firestore or local data
  }
  
  Widget _buildTaskCard(Map<String, dynamic> task) {
    // Build swipeable task card
  }
}
```

## Database Schema

### Collection: `hochzeitskit_progress`
**Path**: `/users/{userId}/hochzeitskit_progress/{categoryId}`

#### Document Structure
```json
{
  "categoryId": "beauty_styling",
  "categoryName": "Beauty & Styling",
  "userId": "firebase-user-id",
  "tasks": [
    {
      "id": "task_1",
      "title": "Brautkleid aussuchen",
      "description": "Verschiedene Kleider anprobieren und das perfekte auswählen",
      "completed": true,
      "completedAt": "2024-01-15T10:00:00Z",
      "notes": "Kleid bei Salon XYZ reserviert",
      "priority": "high",
      "dueDate": "2024-03-01"
    }
  ],
  "progress": 0.75,
  "totalTasks": 12,
  "completedTasks": 9,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

#### Task Object Structure
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique task identifier |
| title | String | Yes | Task title/name |
| description | String | Yes | Detailed task description |
| completed | Boolean | Yes | Completion status |
| completedAt | Timestamp | No | When task was completed |
| notes | String | No | User's personal notes |
| priority | String | No | high/medium/low |
| dueDate | String | No | Suggested due date |

## Categories and Tasks

### 1. Beauty & Styling (beauty_styling.dart)
**Tasks Include**:
- Brautkleid aussuchen
- Schuhe kaufen
- Unterwäsche besorgen
- Frisur-Termin vereinbaren
- Make-up-Termin buchen
- Nagel-Termin vereinbaren
- Accessoires aussuchen
- Brautstrauß bestellen
- Bräutigam-Anzug
- Trauzeugen-Outfits
- Probe-Styling
- Notfall-Kit zusammenstellen

### 2. Band & Musik (band_musik.dart)
**Tasks Include**:
- DJ/Band recherchieren
- Musik-Stil festlegen
- Angebote einholen
- Verträge abschließen
- Playlist erstellen
- Technik klären
- Soundcheck planen
- Backup-Plan erstellen

### 3. Catering (catering.dart)
**Tasks Include**:
- Catering-Stil wählen
- Anbieter recherchieren
- Menü-Verkostung
- Getränke-Auswahl
- Hochzeitstorte bestellen
- Allergien/Diäten berücksichtigen
- Service-Personal klären
- Dekoration abstimmen
- Timing festlegen
- Backup-Optionen
- Rechnung klären
- Trinkgeld planen
- Aufräumen organisieren
- Reste-Verwertung
- Feedback einholen

### 4. Foto & Video (foto_video.dart)
**Tasks Include**:
- Fotografen recherchieren
- Portfolio anschauen
- Preise vergleichen
- Vertrag abschließen
- Shooting-Termine planen
- Locations besprechen
- Wunsch-Motive sammeln
- Backup-Fotograf organisieren

## Validation Rules

### Task Completion
- **Status Change**: Immediate save to Firestore
- **Timestamp**: Auto-generated completion time
- **Sync**: Real-time updates across devices

### Notes Validation
- **Length**: 0-1000 characters
- **Content**: Supports multiline text
- **Auto-save**: Saves after 2 seconds of inactivity

## UI Components

### Category Card Components
- **Icon**: Category-specific emoji/icon
- **Title**: Category name
- **Progress Bar**: Visual completion indicator
- **Task Count**: "X von Y Aufgaben"
- **Tap Action**: Navigate to category detail

### Task Card Components (Swipeable)
- **Checkbox**: Completion toggle
- **Title**: Task name
- **Description**: Expandable description
- **Notes Field**: Personal notes input
- **Due Date**: Optional deadline display

### Swipe Actions
- **Swipe Right**: Mark as complete
- **Swipe Left**: Add/edit notes
- **Long Press**: Show additional options
