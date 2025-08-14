# Global Key Conflicts Documentation

## Overview
This document identifies all GlobalKey usages across the codebase and highlights potential conflicts where the same key variable name is used across multiple widgets.

## Critical Issues Found

### 🚨 **MAJOR CONFLICT: MenueState GlobalKey**
**Issue**: Multiple files use the same variable name `key` for `GlobalKey<MenueState>()`
**Impact**: This can cause widget conflicts and state management issues

#### Files Using `final key = GlobalKey<MenueState>()`:
1. **lib/screens/budget.dart:24**
2. **lib/pages/edit_profile_page.dart:32**
3. **lib/pages/home.dart:19**
4. **lib/pages/to_do_page1.dart:38**
5. **lib/pages/wedding_schedule_page.dart:34**
6. **lib/pages/tables_management_page.dart:31**
7. **lib/pages/inspiration_folder.dart:29**
8. **lib/pages/collaboration_screen.dart:22**
9. **lib/pages/to_do_page.dart:39**

#### Files Using `final Key key = GlobalKey<MenueState>()`:
10. **lib/pages/tanzschule.dart:9**
11. **lib/pages/parsonal_training.dart:10**
12. **lib/pages/catering.dart:8**
13. **lib/pages/checklist.dart:25**
14. **lib/pages/about_me.dart:18**
15. **lib/pages/braut_braeutigam_atelier.dart:8**
16. **lib/pages/hair_makeup.dart:16**
17. **lib/pages/patiserie.dart:9**
18. **lib/pages/trauredner.dart:9**
19. **lib/pages/muenchner_geheimtipp.dart:12**
20. **lib/pages/unterhaltung.dart:9**
21. **lib/pages/location.dart:8**
22. **lib/pages/kosmetische_akupunktur.dart:11**
23. **lib/pages/gaestelist.dart:25**
24. **lib/pages/showroom_event.dart:28**
25. **lib/pages/trauringe.dart:9**
26. **lib/pages/impressum.dart:6**
27. **lib/pages/florist.dart:8**
28. **lib/pages/swipeable_card_test.dart:22**
29. **lib/pages/fotograph.dart:9**
30. **lib/pages/gesang.dart:8**
31. **lib/pages/band_dj.dart:9**
32. **lib/pages/papeterie.dart:9**
33. **lib/pages/chatbot.dart:27**
34. **lib/pages/kontakt.dart:16**

#### Singleton MenuService Key:
35. **lib/services/menu_service.dart:13** - `final menuKey = GlobalKey<MenueState>()`

### 🚨 **CONFLICT: Inline GlobalKey Creation**
**Issue**: Some files create GlobalKey instances inline without storing them
#### Files Using Inline `GlobalKey()`:
1. **lib/pages/bachelorette_party.dart:50** - `Menue.getInstance(GlobalKey())`
2. **lib/pages/hair_makeup.dart:48** - `Menue.getInstance(GlobalKey())`

### 🚨 **CONFLICT: FormState GlobalKey**
**Issue**: Multiple files use `_formKey` for form validation
#### Files Using `final _formKey = GlobalKey<FormState>()`:
1. **lib/screens/signin_screen.dart:19**
2. **lib/screens/signup_screen.dart:21**
3. **lib/screens/forgot_password_screen.dart:15**
4. **lib/pages/edit_profile_page.dart:34**
5. **lib/pages/add_edit_guest_page.dart:19**
6. **lib/pages/add_edit_table_page.dart:17**

### ⚠️ **POTENTIAL CONFLICT: Other GlobalKeys**
#### Unique GlobalKeys (Currently Safe):
1. **lib/pages/chatbot.dart:28** - `final GlobalKey _dashChatKey = GlobalKey()`
2. **lib/widgets/collaboration_todo_tile.dart:41** - `final GlobalKey<_CollaborationTodoTileState> tileKey = GlobalKey()`
3. **lib/screens/newfeature1/screens/wedding_schedule_page1.dart:33** - `final key = GlobalKey<MenueState>()`

## Impact Analysis

### **High Risk Issues:**

#### 1. **MenueState Key Conflicts**
- **Problem**: 34+ files use the same variable name `key` for MenueState
- **Risk**: Widget tree conflicts, state management issues
- **Symptoms**: Menu state not updating correctly, drawer issues
- **Solution**: Use unique variable names or implement singleton pattern

#### 2. **Inline GlobalKey Creation**
- **Problem**: Creating new GlobalKey() instances inline
- **Risk**: Keys are recreated on every build, losing widget state
- **Symptoms**: Widget state resets, performance issues
- **Solution**: Store keys as final variables

### **Medium Risk Issues:**

#### 3. **FormState Key Conflicts**
- **Problem**: Multiple `_formKey` variables across different forms
- **Risk**: Form validation conflicts if forms are used simultaneously
- **Symptoms**: Form validation not working correctly
- **Solution**: Use unique form key names

## Recommended Solutions

### **Solution 1: Implement Singleton Pattern (Recommended)**
```dart
// Use the existing MenuService singleton
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menue.getInstance(MenuService().menuKey),
      // ... rest of widget
    );
  }
}
```

### **Solution 2: Unique Variable Names**
```dart
// Instead of: final key = GlobalKey<MenueState>();
// Use unique names:
final homeMenuKey = GlobalKey<MenueState>();
final budgetMenuKey = GlobalKey<MenueState>();
final todoMenuKey = GlobalKey<MenueState>();
```

### **Solution 3: Fix Inline GlobalKey Creation**
```dart
// BAD: Creates new key on every build
drawer: Menue.getInstance(GlobalKey()),

// GOOD: Store key as final variable
class MyPage extends StatelessWidget {
  final Key menuKey = GlobalKey<MenueState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menue.getInstance(menuKey),
    );
  }
}
```

### **Solution 4: Unique Form Key Names**
```dart
// Instead of: final _formKey = GlobalKey<FormState>();
// Use descriptive names:
final _loginFormKey = GlobalKey<FormState>();
final _signupFormKey = GlobalKey<FormState>();
final _editProfileFormKey = GlobalKey<FormState>();
```

## Priority Fix List

### **Immediate (High Priority)**
1. Fix inline GlobalKey creation in:
   - `lib/pages/bachelorette_party.dart:50`
   - `lib/pages/hair_makeup.dart:48`

2. Implement singleton MenuService pattern across all pages

### **Short Term (Medium Priority)**
1. Rename FormState keys to be unique:
   - `_loginFormKey`, `_signupFormKey`, `_editProfileFormKey`, etc.

2. Update all MenueState keys to use singleton pattern

### **Long Term (Low Priority)**
1. Create a GlobalKey management service
2. Implement key naming conventions
3. Add linting rules to prevent duplicate key names

## Testing Recommendations

### **Test Cases to Verify Fixes:**
1. **Menu State Test**: Open multiple pages with menus simultaneously
2. **Form Validation Test**: Use multiple forms at the same time
3. **Widget State Test**: Verify widgets maintain state correctly
4. **Navigation Test**: Test drawer functionality across all pages

## Monitoring

### **Signs of GlobalKey Conflicts:**
- Menu drawer not opening/closing correctly
- Form validation not working
- Widget state being lost unexpectedly
- Flutter warnings about duplicate keys
- Performance issues with widget rebuilds

## Best Practices

### **GlobalKey Naming Convention:**
```dart
// Format: [widget/page]_[purpose]_key
final homeMenuKey = GlobalKey<MenueState>();
final loginFormKey = GlobalKey<FormState>();
final chatDashKey = GlobalKey<DashChatState>();
```

### **GlobalKey Usage Guidelines:**
1. Always store GlobalKeys as final variables
2. Never create GlobalKeys inline in build methods
3. Use descriptive names that indicate purpose
4. Consider singleton patterns for shared keys
5. Avoid reusing the same variable name across files
