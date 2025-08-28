import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:four_secrets_wedding_app/routes/routes.dart';
import 'package:four_secrets_wedding_app/services/subscription/revenuecat_subscription_service.dart';
import 'package:four_secrets_wedding_app/widgets/auth_background.dart';
import 'package:four_secrets_wedding_app/widgets/auth_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/snackbar_helper.dart';
import '../constants/app_constants.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _signinFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _autoValidate = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['preventAutoValidate'] == true) {
        setState(() {
          _autoValidate = false;
        });
      }

      _loadSavedCredentials();
    });
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberMe) {
        final email = prefs.getString('saved_email') ?? '';
        final password = prefs.getString('saved_password') ?? '';

        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _autoValidate = true);

    if (!_signinFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      print('🟢 Attempting sign in for: $email');

      await _saveCredentials();

      final userModel = await AuthService().signIn(
        email: email,
        password: password,
      );

      print('🟢 Sign in successful: ${userModel.toString()}');

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.emailVerificationPage,
          (route) => false,
        );
        return;
      }

      // Check subscription status after successful sign in
      await _checkSubscriptionAndNavigate(userModel);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = AppConstants.userNotFoundError;
          break;
        case 'wrong-password':
          errorMessage = AppConstants.wrongPasswordError;
          break;
        case 'invalid-email':
          errorMessage = AppConstants.invalidEmailError;
          break;
        case 'user-disabled':
          errorMessage = AppConstants.userDisabledError;
          break;
        case 'too-many-requests':
          errorMessage = AppConstants.tooManyRequestsError;
          break;
        case 'network-request-failed':
          errorMessage = AppConstants.networkRequestFailedError;
          break;
        case 'operation-not-allowed':
          errorMessage = AppConstants.operationNotAllowedError;
          break;
        default:
          errorMessage =
              '${AppConstants.defaultSignInError}${e.message ?? 'Please try again'}';
      }

      SnackBarHelper.showErrorSnackBar(context, errorMessage);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(context, AppConstants.unexpectedError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkSubscriptionAndNavigate(UserModel userModel) async {
    try {
      // Initialize RevenueCat with user ID
      final revenueCatService = RevenueCatService();
      await revenueCatService.initialize(userModel.uid);

      // Check if user has active subscription
      final hasActiveSubscription =
          await revenueCatService.hasActiveSubscription();

      // Update Firebase with current subscription status
      await revenueCatService.updateSubscriptionStatusInFirebase(
          await revenueCatService.getCustomerInfo());

      if (hasActiveSubscription) {
        // User has active subscription - navigate to home
        SnackBarHelper.showSuccessSnackBar(
            context, AppConstants.welcomeBackMessage);

        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.homePage,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.subscriptionPreviewScreen,
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error checking subscription: $e');

      // Fallback: Check the subscription status from Firestore
      if (userModel.isSubscribed) {
        // Use Firestore data if RevenueCat check fails
        SnackBarHelper.showSuccessSnackBar(
            context, AppConstants.welcomeBackMessage);

        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.homePage,
          (route) => false,
        );
      } else {
        // Redirect to subscription screen
        SnackBarHelper.showInfoSnackBar(
            context, 'Bitte wählen Sie ein Abonnement, um fortzufahren');

        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.subscriptionPreviewScreen,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _signinFormKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 32, bottom: 32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppConstants.appLogo,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Welcome Text
                    Center(
                      child: const Text(
                        AppConstants.signInTitle,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.signInSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Form Fields
                    AuthTextField(
                      label: AppConstants.emailLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.emptyEmailError;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return AppConstants.emailValidationError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      label: AppConstants.passwordLabel,
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.emptyPasswordError;
                        }
                        return null;
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/forgot-password');
                          },
                          child: Text(
                            AppConstants.forgotPasswordLink,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromARGB(255, 107, 69, 106),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.6),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                AppConstants.signInButtonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    // Remember Me Checkbox
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: const Color.fromARGB(255, 107, 69, 106),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return Colors.transparent;
                          }),
                          side:
                              const BorderSide(color: Colors.white, width: 2.0),
                        ),
                        const Text(
                          AppConstants.rememberMeLabel,
                          style: TextStyle(color: Colors.white),
                        ),

                        // Forgot Password Link
                      ],
                    ),

                    // Sign Up Link
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppConstants.noAccountText,
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text(
                            AppConstants.signUpLink,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Mit der Nutzung akzeptieren Sie ',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'Datenschutz',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                    'https://www.4secrets-wedding-planner.de/datenschutz-app/',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                            TextSpan(
                              text: ' & ',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: 'AGB',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                    'https://www.4secrets-wedding-planner.de/agb',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
