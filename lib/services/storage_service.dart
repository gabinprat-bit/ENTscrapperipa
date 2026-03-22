import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // Token — stocké dans SharedPreferences (pas de Keychain nécessaire)
  Future<void>    saveToken(String v) async => (await _p).setString('ent_token', v);
  Future<String?> getToken()          async => (await _p).getString('ent_token');
  Future<void>    deleteToken()       async => (await _p).remove('ent_token');

  // Prefs
  Future<void>    saveServerUrl(String v) async => (await _p).setString('server_url', v);
  Future<String?> getServerUrl()          async => (await _p).getString('server_url');

  Future<void>    saveUserName(String v)  async => (await _p).setString('user_name', v);
  Future<String>  getUserName()           async => (await _p).getString('user_name') ?? '';

  Future<bool>    getNotifNotes()         async => (await _p).getBool('notif_notes')   ?? true;
  Future<void>    setNotifNotes(bool v)   async => (await _p).setBool('notif_notes', v);

  Future<bool>    getNotifDevoirs()       async => (await _p).getBool('notif_devoirs') ?? true;
  Future<void>    setNotifDevoirs(bool v) async => (await _p).setBool('notif_devoirs', v);

  Future<bool>    getActiveMode()         async => (await _p).getBool('active_mode')   ?? true;
  Future<void>    setActiveMode(bool v)   async => (await _p).setBool('active_mode', v);

  Future<bool>    getPrefsSet()           async => (await _p).getBool('prefs_set')     ?? false;
  Future<void>    setPrefsSet(bool v)     async => (await _p).setBool('prefs_set', v);

  Future<void> clearAll() async {
    final p = await _p;
    await p.remove('ent_token');
    await p.remove('user_name');
    await p.remove('prefs_set');
  }
}
