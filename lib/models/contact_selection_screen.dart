import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:four_secrets_wedding_app/config/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactSelectionScreen extends StatefulWidget {
  const ContactSelectionScreen({super.key});

  @override
  State<ContactSelectionScreen> createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> contacts = [];
  Contact? selectedContact;
  bool _isLoading = false;
  bool _permissionGranted = false;
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode(); // ✅ FocusNode

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // ✅ cleanup
    super.dispose();
  }

  Future<void> _checkPermissionAndLoadContacts() async {
    setState(() => _isLoading = true);

    try {
      final granted = await FlutterContacts.requestPermission(readonly: true);

      if (granted) {
        await _loadContacts();
        setState(() => _permissionGranted = true);
      } else {
        setState(() => _permissionGranted = false);
      }
    } catch (e) {
      _showErrorSnackbar('Error accessing contacts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContacts() async {
    final allContacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    final filtered = allContacts.where((c) => c.displayName.isNotEmpty).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    setState(() {
      contacts = filtered;
    });

    print("Loaded contacts: ${contacts.length}");
  }

  void _confirmSelection() {
    if (selectedContact == null) {
      _showErrorSnackbar('Bitte wählen Sie einen Kontakt aus');
      return;
    }
    Navigator.pop(context, selectedContact!.displayName);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return contacts;
    return contacts
        .where(
          (c) =>
              c.displayName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  String _getPhoneNumber(Contact c) =>
      c.phones.isNotEmpty ? c.phones.first.number : '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ tap anywhere to hide keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          title: const Text("Kontakt auswählen"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.arrowsRotate,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: _checkPermissionAndLoadContacts,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 🔍 Search bar with FocusNode
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Kontakte suchen...',
                    prefixIcon: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_permissionGranted
                  ? _buildEmptyState(
                      icon: Icons.lock_outline,
                      title: "Zugriff auf Kontakte benötigt",
                      message:
                          "Bitte erlauben Sie den Zugriff in den Einstellungen.",
                      action: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => openAppSettings(),
                        child: const Text("Einstellungen öffnen"),
                      ),
                    )
                  : contacts.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.contacts_outlined,
                      title: "Keine Kontakte gefunden",
                      message:
                          "Stellen Sie sicher, dass Kontakte vorhanden sind.",
                    )
                  : _filteredContacts.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.search_off,
                      title: "Keine Kontakte gefunden",
                      message: "Ihre Suche ergab keine Ergebnisse.",
                    )
                  : ListView.separated(
                      itemCount: _filteredContacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, i) {
                        final c = _filteredContacts[i];
                        final selected = c == selectedContact;

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade400,
                              width: 1.0,
                            ),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            tileColor: Colors.transparent,
                            selected: selected,
                            selectedTileColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                c.displayName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(c.displayName),
                            subtitle: Text(_getPhoneNumber(c)),
                            trailing: selected
                                ? const Icon(
                                    FontAwesomeIcons.squareCheck,
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                selectedContact = selected ? null : c;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: selectedContact != null
            ? FloatingActionButton.extended(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                onPressed: _confirmSelection,
                icon: const Icon(Icons.check),
                label: const Text("Auswählen"),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}
