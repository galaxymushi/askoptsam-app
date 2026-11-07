import 'package:flutter/widgets.dart';

import 'models.dart';
import 'services/auth_service.dart';
import 'services/chat_store.dart';
import 'services/settings_controller.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.settings,
    required this.auth,
    required this.store,
  });

  final SettingsController settings;
  final AuthService auth;
  final ChatStore store;

  AppUser? user;
  bool ready = false;

  bool get isCloud => auth.isCloud;

  Future<void> restoreSession() async {
    try {
      user = await auth.restore();
    } catch (error) {
      debugPrint('Could not restore session: $error');
    }
    ready = true;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    user = await auth.signIn(email, password);
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    user = await auth.signUp(name, email, password);
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    await auth.updateName(name);
    user = user?.copyWith(name: name.trim());
    notifyListeners();
  }

  Future<void> signOut() async {
    await auth.signOut();
    user = null;
    notifyListeners();
  }

  Future<void> sendReset(String email) => auth.sendReset(email);
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }
}
