import 'package:flutter/material.dart';
import 'package:four_secrets_wedding_app/services/theme_service.dart';

/// Wrapper widget that ensures light mode system UI is applied
/// Use this to wrap screens that need consistent light mode appearance
/// Especially important for Huawei and other Android devices
class LightModeWrapper extends StatefulWidget {
  final Widget child;
  final bool applySystemUI;

  const LightModeWrapper({
    Key? key,
    required this.child,
    this.applySystemUI = true,
  }) : super(key: key);

  @override
  State<LightModeWrapper> createState() => _LightModeWrapperState();
}

class _LightModeWrapperState extends State<LightModeWrapper>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Apply light mode system UI when widget is created
    if (widget.applySystemUI) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ThemeService.applyLightModeSystemUI();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Reapply light mode when app comes back to foreground
    // This is especially important for Huawei devices
    if (state == AppLifecycleState.resumed && widget.applySystemUI) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ThemeService.applyLightModeSystemUI();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension to easily wrap any widget with light mode enforcement
extension LightModeExtension on Widget {
  /// Wrap this widget with light mode enforcement
  Widget withLightMode({bool applySystemUI = true}) {
    return LightModeWrapper(
      applySystemUI: applySystemUI,
      child: this,
    );
  }
}
