# Eigene Dienstleister (Custom Service Providers) Documentation

## Overview
The Eigene Dienstleister feature allows couples to manage their custom wedding service providers, track contacts, contracts, payments, and communication history.

## User Flow

### 1. Initial Access
- **Entry Point**: Main dashboard → "Eigene Dienstleister" card
- **Authentication**: Requires logged-in user
- **Navigation**: `lib/pages/eigene_dienstleister.dart`

### 2. Main Interface
```
┌─────────────────────────────────────┐
│ Eigene Dienstleister                │
│ [+ Neuen Dienstleister hinzufügen]  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📸 Fotograf Schmidt             │ │
│ │ Hochzeitsfotografie             │ │
│ │ ✅ Vertrag unterschrieben       │ │
│ │ 💰 €2.500 (€500 bezahlt)       │ │
│ │ 📞 +49123456789                │ │
│ │ [Details] [Bearbeiten]         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🎵 DJ Music Masters            │ │
│ │ Musik & Entertainment           │ │
│ │ ⏳ Angebot ausstehend          │ │
│ │ 💰 €1.200 (€0 bezahlt)        │ │
│ │ [Details] [Bearbeiten]         │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 3. Adding New Service Provider
**Trigger**: Tap "+ Neuen Dienstleister hinzufügen" button
**Form Fields**:
- **Name**: Text input (required)
- **Kategorie**: Dropdown selection (required)
- **Beschreibung**: Text area (optional)
- **Kontaktperson**: Text input (optional)
- **Telefon**: Phone input with validation
- **E-Mail**: Email input with validation
- **Website**: URL input (optional)
- **Adresse**: Text input (optional)
- **Preis**: Currency input (optional)
- **Status**: Dropdown (Anfrage/Angebot/Vertrag/Abgeschlossen)

### 4. Service Provider Details
**Trigger**: Tap "Details" on provider card
**Detail View Sections**:
- **Kontaktinformationen**: All contact details
- **Vertragsstatus**: Contract and payment tracking
- **Kommunikation**: Message history and notes
- **Dokumente**: File attachments and contracts
- **Termine**: Scheduled appointments and deadlines

### 5. Communication Tracking
- **Add Notes**: Record conversations and decisions
- **Email Integration**: Track email communications
- **Appointment Scheduling**: Set meetings and deadlines
- **Document Storage**: Upload contracts and invoices

## Technical Implementation

### File Structure
```
lib/pages/eigene_dienstleister.dart
├── EigeneDienstleisterPage (StatefulWidget)
├── _EigeneDienstleisterPageState
├── _buildProviderCard()
├── _showAddProviderDialog()
├── _showProviderDetails()
├── _addProvider()
├── _editProvider()
├── _deleteProvider()
├── _loadProviders()
└── _updateProviderStatus()

lib/widgets/service_providers/
├── provider_card.dart
├── provider_details_dialog.dart
├── add_provider_form.dart
├── communication_log.dart
└── document_manager.dart
```

### Key Methods

#### _loadProviders()
```dart
Future<void> _loadProviders() async {
  // Fetches all service providers from Firestore
  // Orders by category and status
  // Updates UI state with provider data
}
```

#### _addProvider()
```dart
Future<void> _addProvider(Map<String, dynamic> providerData) async {
  // Validates provider data
  // Checks for duplicate entries
  // Creates new provider document
  // Sends confirmation email if applicable
}
```

#### _updateProviderStatus()
```dart
Future<void> _updateProviderStatus(String providerId, String newStatus) async {
  // Updates provider status
  // Logs status change
  // Triggers workflow actions
  // Notifies collaborators
}
```

## Database Schema

### Collection: `service_providers`
**Path**: `/users/{userId}/service_providers/{providerId}`

#### Provider Document Structure
```json
{
  "id": "auto-generated-id",
  "userId": "firebase-user-id",
  "name": "Fotograf Schmidt",
  "category": "Fotografie",
  "description": "Spezialisiert auf Hochzeitsfotografie mit natürlichem Stil",
  "contactPerson": "Hans Schmidt",
  "phone": "+49123456789",
  "email": "info@fotograf-schmidt.de",
  "website": "https://www.fotograf-schmidt.de",
  "address": {
    "street": "Musterstraße 123",
    "city": "München",
    "postalCode": "80331",
    "country": "Deutschland"
  },
  "pricing": {
    "totalAmount": 2500.00,
    "currency": "EUR",
    "paidAmount": 500.00,
    "remainingAmount": 2000.00,
    "paymentTerms": "50% Anzahlung, Rest nach Hochzeit"
  },
  "status": "contract_signed",
  "contractDetails": {
    "contractSigned": true,
    "contractDate": "2024-01-15",
    "deliveryDate": "2024-06-15",
    "cancellationPolicy": "Kostenlose Stornierung bis 30 Tage vorher"
  },
  "communications": [
    {
      "id": "comm-1",
      "type": "email",
      "date": "2024-01-10T10:00:00Z",
      "subject": "Angebot Hochzeitsfotografie",
      "content": "Vielen Dank für Ihre Anfrage...",
      "attachments": ["angebot.pdf"]
    }
  ],
  "documents": [
    {
      "id": "doc-1",
      "name": "Vertrag Fotografie",
      "type": "contract",
      "url": "gs://bucket/contracts/contract-123.pdf",
      "uploadDate": "2024-01-15T10:00:00Z"
    }
  ],
  "appointments": [
    {
      "id": "appt-1",
      "title": "Engagement Shooting",
      "date": "2024-03-15T14:00:00Z",
      "location": "Englischer Garten München",
      "notes": "Casual Outfit mitbringen"
    }
  ],
  "tags": ["empfohlen", "lokal", "premium"],
  "rating": 4.8,
  "notes": "Sehr professionell, pünktlich, kreative Ideen",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z"
}
```

#### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| name | String | Yes | 1-100 chars | Provider/company name |
| category | String | Yes | Predefined list | Service category |
| contactPerson | String | No | 1-100 chars | Main contact person |
| phone | String | No | Valid phone format | Contact phone number |
| email | String | No | Valid email format | Contact email address |
| website | String | No | Valid URL format | Company website |
| totalAmount | Number | No | Positive number | Total service cost |
| status | String | Yes | Predefined list | Current status |
| contractSigned | Boolean | No | true/false | Contract status |

## Service Categories

### Predefined Categories
1. **Fotografie** - Wedding photographers
2. **Videografie** - Wedding videographers  
3. **Musik & DJ** - Entertainment services
4. **Catering** - Food and beverage services
5. **Location** - Venue and reception sites
6. **Blumen & Dekoration** - Floral and decoration
7. **Transport** - Transportation services
8. **Beauty & Styling** - Hair, makeup, styling
9. **Einladungen** - Invitation and stationery
10. **Sonstiges** - Other custom services

## Validation Rules

### Contact Information Validation
```dart
bool validateEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool validatePhone(String phone) {
  return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
}

bool validateWebsite(String url) {
  return Uri.tryParse(url)?.hasAbsolutePath ?? false;
}
```

### Business Logic Validation
- **Date Validation**: Appointment dates must be in future

## UI Components

### Provider Card Components
- **Category Icon**: Visual category identifier
- **Provider Name**: Company/person name
- **Status Badge**: Color-coded status indicator
- **Contact Summary**: Phone and email quick access
- **Price Summary**: Total cost and payment status
- **Action Buttons**: Details, edit, delete options

### Add/Edit Provider Form
- **Basic Information**: Name, category, description
- **Contact Details**: Phone, email, website, address
- **Pricing**: Total amount, payment terms
- **Contract Status**: Signed status, dates
- **Notes**: Additional information

### Provider Details View
- **Tabbed Interface**: Organize information sections
- **Communication Log**: Chronological message history
- **Appointment Calendar**: Scheduled meetings

## Error Handling

### Common Error Scenarios
1. **Invalid Email**: "Bitte geben Sie eine gültige E-Mail-Adresse ein"
2. **Invalid Phone**: "Telefonnummer ist nicht gültig"
3. 
### Validation Feedback
- **Real-time Validation**: Immediate field validation
- **Error Messages**: Clear, actionable error descriptions
- **Success Indicators**: Confirmation of successful actions
- **Progress Indicators**: Show upload/save progress

## Advanced Features

### Communication Integration
```dart
Future<void> sendEmail(String providerId, String subject, String body) async {
  // Integrate with email service
  // Log communication in provider record
  // Track email delivery status
}
```

### Document Management
- **File Upload**: Support PDF, DOC, images
- **Sharing**: Share documents with collaborators
- **Templates**: Contract templates for common services

### Workflow Automation
- **Reminder Notifications**: Deadline and appointment alerts

