import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Token (Keychain / Keystore) ────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: 'ent_token', value: token);

  Future<String?> getToken() => _storage.read(key: 'ent_token');

  Future<void> deleteToken() => _storage.delete(key: 'ent_token');

  // ── URL Serveur (UserDefaults / SharedPreferences) ─────────────────────────
  Future<void> saveServerUrl(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('server_url', url);
  }

  Future<String?> getServerUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('server_url');
  }

  // ── Nom affiché ────────────────────────────────────────────────────────────
  Future<void> saveUserName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('user_name', name);
  }

  Future<String> getUserName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('user_name') ?? '';
  }

  // ── Préférences notifs ─────────────────────────────────────────────────────
  Future<bool> getNotifNotes() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('notif_notes') ?? true;
  }

  Future<void> setNotifNotes(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_notes', v);
  }

  Future<bool> getNotifDevoirs() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('notif_devoirs') ?? true;
  }

  Future<void> setNotifDevoirs(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_devoirs', v);
  }

  Future<bool> getActiveMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('active_mode') ?? true;
  }

  Future<void> setActiveMode(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('active_mode', v);
  }

  Future<bool> getPrefsSet() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('prefs_set') ?? false;
  }

  Future<void> setPrefsSet(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('prefs_set', v);
  }
}
