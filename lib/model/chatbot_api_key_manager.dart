import 'package:cloud_firestore/cloud_firestore.dart';

class ApiKeyManager {
  static String? _apiKey;
  static bool _isInitialized = false;

  /// Gibt den aktuellen API Key zurück
  static String? get apiKey => _apiKey;

  /// Prüft ob der Manager initialisiert wurde
  static bool get isInitialized => _isInitialized;

  /// Initialisiert den API Key Manager
  /// Lädt den API Key aus der .env Datei
  static Future<void> initialize() async {
    try {
      print('🔑 Initialisiere API Key Manager...');

      // Firestore-Pfad: app_settings/api_keys/chatbot_key
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('app_settings')
          .doc('api_keys')
          .get();

      if (snapshot.exists) {
        _apiKey = snapshot.data()?['chatbot_key'];

        if (_apiKey == null || _apiKey!.isEmpty) {
          print('⚠️ chatbot_key nicht in Firestore gefunden oder leer.');
          _apiKey = null;
        } else {
          if (!_apiKey!.startsWith('sk-')) {
            print('⚠️ API Key hat falsches Format (sollte mit sk- beginnen)');
            _apiKey = null;
          } else {
            print(
                '✅ API Key erfolgreich geladen (${_apiKey!.substring(0, 10)}...)');
          }
        }
      } else {
        print('⚠️ Firestore-Dokument app_settings/api_keys existiert nicht.');
        _apiKey = null;
      }

      _isInitialized = true;
    } catch (e) {
      print('❌ Fehler beim Laden des API Keys aus Firestore: $e');
      _apiKey = null;
      _isInitialized = true; // Trotzdem als initialisiert markieren
    }
  }

  /// Setzt den API Key manuell (für Tests oder Fallback)
  static void setApiKey(String apiKey) {
    if (apiKey.isNotEmpty && apiKey.startsWith('sk-')) {
      _apiKey = apiKey;
      print('✅ API Key manuell gesetzt');
    } else {
      print('⚠️ Ungültiger API Key beim manuellen Setzen');
    }
  }

  /// Validiert den aktuellen API Key
  static bool isValidApiKey() {
    return _apiKey != null &&
        _apiKey!.isNotEmpty &&
        _apiKey!.startsWith('sk-') &&
        _apiKey!.length > 20; // Mindestlänge für OpenAI Keys
  }

  /// Gibt Debug-Informationen zurück
  static Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'hasApiKey': _apiKey != null,
      'isValidFormat': _apiKey?.startsWith('sk-') ?? false,
      'keyLength': _apiKey?.length ?? 0,
      'keyPreview':
          _apiKey != null ? '${_apiKey!.substring(0, 10)}...' : 'null',
    };
  }

  /// Reset für Tests
  static void reset() {
    _apiKey = null;
    _isInitialized = false;
  }
}
