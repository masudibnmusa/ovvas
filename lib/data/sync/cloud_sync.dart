import 'package:flutter/foundation.dart';

/// Account and cloud backup. The store talks to this; the screens read it
/// through the store.
abstract class CloudSync extends ChangeNotifier {
  /// False when this build has no cloud backend set up.
  bool get available => true;
  bool get signedIn;
  String get accountEmail;

  /// When everything on this phone was last confirmed in the cloud.
  DateTime? get lastBackup;

  /// Set by the store. Called after cloud changes were saved to the local
  /// database, so the store can reload them.
  Future<void> Function()? onRemoteChange;

  /// Starts sign-in. With a browser-based sign-in, [signedIn] turns true
  /// later, when the user comes back to the app.
  Future<void> signIn();

  /// Signs out. Data stays on the phone.
  Future<void> signOut();

  /// Uploads local changes and downloads remote ones. Returns false if the
  /// sync could not finish (offline, not signed in, server error).
  Future<bool> syncNow();

  /// Called after every local change. Implementations should batch these.
  void requestSync();
}

/// Used when no cloud backend is configured. Data stays on the phone.
class LocalOnlyCloudSync extends CloudSync {
  @override
  bool get available => false;
  @override
  bool get signedIn => false;
  @override
  String get accountEmail => '';
  @override
  DateTime? get lastBackup => null;
  @override
  Future<void> signIn() async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<bool> syncNow() async => false;
  @override
  void requestSync() {}
}

/// Pretends every change is backed up instantly. For tests and demos.
class FakeCloudSync extends CloudSync {
  FakeCloudSync({DateTime Function()? clock, this._signedIn = true}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  bool _signedIn;
  DateTime? _lastBackup;

  @override
  bool get signedIn => _signedIn;
  @override
  String get accountEmail => 'nabila@example.com';
  @override
  DateTime? get lastBackup => _lastBackup;

  @override
  Future<void> signIn() async {
    _signedIn = true;
    _lastBackup = _clock();
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _lastBackup = null;
    notifyListeners();
  }

  @override
  Future<bool> syncNow() async {
    if (!_signedIn) return false;
    _lastBackup = _clock();
    notifyListeners();
    return true;
  }

  @override
  void requestSync() {
    // The store notifies listeners right after this, so no notify here.
    if (_signedIn) _lastBackup = _clock();
  }
}
