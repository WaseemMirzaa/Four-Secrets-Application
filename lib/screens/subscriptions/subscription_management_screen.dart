import 'package:flutter/material.dart';
import 'package:four_secrets_wedding_app/menue.dart';
import 'package:four_secrets_wedding_app/routes/routes.dart';
import 'package:four_secrets_wedding_app/services/auth_service.dart';
import 'package:four_secrets_wedding_app/utils/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user_model.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionManagementScreenState createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  UserModel? _userData;
  DateTime? _subscriptionExpiryDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _userData = await _authService.getCurrentUser();

      if (_userData?.subscriptionExpiryDate != null) {
        _subscriptionExpiryDate = _userData!.subscriptionExpiryDate;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
        context,
        'Fehler beim Laden der Abonnementdaten',
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openManageSubscription() async {
    final platform = _userData?.subscriptionPlatform ?? 'android';
    final url = Uri.parse(platform == 'ios'
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      SnackBarHelper.showInfoSnackBar(
        context,
        'Bitte verwalten Sie Ihr Abonnement direkt in den Einstellungen Ihres App Stores.',
      );
    }
  }

  String _getSubscriptionStatusText() {
    if (_userData == null) return 'Unbekannt';
    return _userData!.isSubscribed ? 'Aktiv' : 'Inaktiv';
  }

  String _getPlanName() {
    if (_userData == null) return 'Unbekannt';

    final plan = _userData!.subscriptionPlan?.toLowerCase() ?? '';
    if (plan.contains("monthly")) return "Premium Monatlich";
    if (plan.contains("yearly")) return "Premium Jährlich";

    return plan.isNotEmpty ? 'Premium $plan' : 'Unbekannter Plan';
  }

  String _getRenewalInfo() {
    if (_subscriptionExpiryDate != null) {
      return 'Läuft ab am: ${DateFormat('dd.MM.yyyy').format(_subscriptionExpiryDate!)}';
    }
    return 'Keine Verlängerungsinformationen verfügbar';
  }

  String _getPlatformInfo() {
    if (_userData == null) return 'Unbekannt';

    final platform = _userData!.subscriptionPlatform?.toLowerCase() ?? '';
    if (platform == 'ios') return 'Apple App Store';
    if (platform == 'android') return 'Google Play Store';

    return platform.isNotEmpty ? platform : 'Unbekannte Plattform';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menue.getInstance(),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Abonnement verwalten'),
        backgroundColor: const Color(0xFF6B456A),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6B456A).withOpacity(0.1),
              const Color(0xFFF8F5F9),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B456A)),
                ),
              )
            : _userData != null && !_userData!.isSubscribed
                ? _buildSubscriptionDetails()
                : _buildNoSubscription(),
      ),
    );
  }

  Widget _buildNoSubscription() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.subscriptions_outlined,
                size: 64,
                color: Color(0xFF6B456A),
              ),
            ),
            const SizedBox(height: 30),
            GlassCard(
              child: Column(
                children: [
                  const Text(
                    'Kein aktives Abonnement',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A3A49),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Sie haben derzeit kein aktives Abonnement. Abonnieren Sie, um auf alle Premium-Funktionen zuzugreifen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(RouteManager.subscriptionScreen);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B456A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: const Color(0xFF6B456A).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Jetzt abonnieren',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription Status Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B456A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Abo-Status: ${_getSubscriptionStatusText()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A3A49),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  Icons.workspace_premium_rounded,
                  _getPlanName(),
                  color: const Color(0xFF6B456A),
                ),
                const SizedBox(height: 15),
                _buildDetailRow(
                  Icons.store_rounded,
                  'Plattform: ${_getPlatformInfo()}',
                ),
                const SizedBox(height: 15),
                _buildDetailRow(
                  Icons.calendar_today_rounded,
                  _getRenewalInfo(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Manage Subscription Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Abonnement verwalten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A3A49),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sie können Ihr Abonnement über den ${_getPlatformInfo()} verwalten, kündigen oder ändern.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openManageSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B456A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: const Color(0xFF6B456A).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Abonnement verwalten',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Update Subscription Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Abonnement ändern',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A3A49),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hinweis: Dein Jahresabo läuft bis zum Ende der Laufzeit. Danach startet automatisch das Monatsabo, falls du gewechselt hast. Wechsel vom Monats- zum Jahresabo wird sofort übernommen..',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        RouteManager.updateSubscriptionScreen,
                        arguments: {
                          'currentPlan': _userData?.subscriptionPlan,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6B456A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: Color(0xFF6B456A), width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'Abonnement ändern',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          color: color ?? Colors.grey[700],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GlassCard({Key? key, required this.child, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
