import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // ── Auth ───────────────────────────────────────────────────────────────────
  bool isLoggedIn  = false;
  bool isLoading   = false;
  String loginError = '';
  String userName  = '';
  String? _token;
  String serverUrl = '';

  // ── Prefs ──────────────────────────────────────────────────────────────────
  bool notifNotes   = true;
  bool notifDevoirs = true;
  bool activeMode   = true;
  bool prefsSet     = false;

  // ── Data ───────────────────────────────────────────────────────────────────
  List<NoteMatiere> notes   = [];
  List<Devoir>      devoirs = [];
  String            lastUpdate = '';
  bool              dataLoading = false;

  // ── Services ───────────────────────────────────────────────────────────────
  final _storage = StorageService();
  final _notifs  = NotificationService();
  ApiService? _api;
  Timer? _pollTimer;

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    serverUrl     = await _storage.getServerUrl() ?? '';
    notifNotes    = await _storage.getNotifNotes();
    notifDevoirs  = await _storage.getNotifDevoirs();
    activeMode    = await _storage.getActiveMode();
    prefsSet      = await _storage.getPrefsSet();
    userName      = await _storage.getUserName();
    _token        = await _storage.getToken();

    if (_token != null && serverUrl.isNotEmpty) {
      _api = ApiService(serverUrl: serverUrl);
      await _tryRestoreSession();
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> login(String identifiant, String mdp) async {
    if (serverUrl.isEmpty) {
      loginError = 'Configure d\'abord l\'URL du serveur.';
      notifyListeners();
      return;
    }
    isLoading  = true;
    loginError = '';
    notifyListeners();

    _api = ApiService(serverUrl: serverUrl);
    final result = await _api!.login(identifiant, mdp);

    if (result['ok'] == true) {
      _token   = result['token'] as String;
      userName = result['user']  as String? ?? identifiant;
      isLoggedIn = true;
      await _storage.saveToken(_token!);
      await _storage.saveUserName(userName);
      await fetchData();
      if (activeMode) _startPolling();
    } else {
      loginError = result['error'] as String? ?? 'Connexion échouée.';
    }
    isLoading = false;
    notifyListeners();
  }

  // ── Fetch data ─────────────────────────────────────────────────────────────
  Future<void> fetchData() async {
    if (_token == null || _api == null) return;
    dataLoading = true;
    notifyListeners();

    final result = await _api!.fetchData(_token!);

    if (result['ok'] == true) {
      notes = (result['notes'] as List<dynamic>)
          .map((e) => NoteMatiere.fromJson(e as Map<String, dynamic>))
          .toList();
      devoirs = (result['devoirs'] as List<dynamic>)
          .map((e) => Devoir.fromJson(e as Map<String, dynamic>))
          .toList();
      lastUpdate = result['last_update'] as String? ?? '';

      // Notifs
      final notifsList = result['notifications'] as List<dynamic>? ?? [];
      for (final n in notifsList) {
        final notif = ServerNotif.fromJson(n as Map<String, dynamic>);
        if (notif.type == 'note'   && notifNotes)   await _notifs.show(notif.title, notif.body);
        if (notif.type == 'devoir' && notifDevoirs) await _notifs.show(notif.title, notif.body);
      }
    } else {
      // Session expirée
      isLoggedIn = false;
      _token     = null;
      await _storage.deleteToken();
    }
    dataLoading = false;
    notifyListeners();
  }

  Future<String> fetchDevoirDetail(String url) async {
    if (_token == null || _api == null) return 'Non connecté.';
    return _api!.fetchDevoirDetail(_token!, url);
  }

  // ── Polling 30s ───────────────────────────────────────────────────────────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchData());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void startPolling() {
    if (isLoggedIn) _startPolling();
  }

  // ── Prefs setters ──────────────────────────────────────────────────────────
  Future<void> setNotifNotes(bool v) async {
    notifNotes = v;
    await _storage.setNotifNotes(v);
    notifyListeners();
  }

  Future<void> setNotifDevoirs(bool v) async {
    notifDevoirs = v;
    await _storage.setNotifDevoirs(v);
    notifyListeners();
  }

  Future<void> setActiveMode(bool v) async {
    activeMode = v;
    await _storage.setActiveMode(v);
    if (v) _startPolling(); else stopPolling();
    notifyListeners();
  }

  Future<void> setPrefsSet(bool v) async {
    prefsSet = v;
    await _storage.setPrefsSet(v);
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    serverUrl = url;
    await _storage.saveServerUrl(url);
    notifyListeners();
  }

  // ── Toggle devoir fait ─────────────────────────────────────────────────────
  void toggleDevoir(String id) {
    final idx = devoirs.indexWhere((d) => d.id == id);
    if (idx != -1) {
      devoirs[idx].fait = !devoirs[idx].fait;
      notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    if (_token != null && _api != null) await _api!.logout(_token!);
    stopPolling();
    _token     = null;
    isLoggedIn = false;
    prefsSet   = false;
    notes      = [];
    devoirs    = [];
    userName   = '';
    await _storage.deleteToken();
    await _storage.setPrefsSet(false);
    notifyListeners();
  }

  // ── Restore session ────────────────────────────────────────────────────────
  Future<void> _tryRestoreSession() async {
    final result = await _api!.fetchData(_token!);
    if (result['ok'] == true) {
      notes = (result['notes'] as List<dynamic>)
          .map((e) => NoteMatiere.fromJson(e as Map<String, dynamic>))
          .toList();
      devoirs = (result['devoirs'] as List<dynamic>)
          .map((e) => Devoir.fromJson(e as Map<String, dynamic>))
          .toList();
      lastUpdate = result['last_update'] as String? ?? '';
      isLoggedIn = true;
      if (activeMode) _startPolling();
    } else {
      _token = null;
      await _storage.deleteToken();
    }
  }
}
