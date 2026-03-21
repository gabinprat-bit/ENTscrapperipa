import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // ── Auth ───────────────────────────────────────────────────────────────────
  bool   isLoggedIn  = false;
  bool   isLoading   = false;
  String loginError  = '';
  String userName    = '';
  String serverUrl   = 'http://51.83.6.7:20312';
  String? _token;

  // ── Prefs ──────────────────────────────────────────────────────────────────
  bool notifNotes   = true;
  bool notifDevoirs = true;
  bool activeMode   = true;
  bool prefsSet     = false;  // true = configuré une seule fois

  // ── Data ───────────────────────────────────────────────────────────────────
  List<NoteMatiere> notes   = [];
  List<Devoir>      devoirs = [];
  bool              dataLoading = false;

  // ── Moyenne générale ───────────────────────────────────────────────────────
  String? get moyenneGenerale {
    final vals = notes.map((m) => m.moyenneNum).whereType<double>().toList();
    if (vals.isEmpty) return null;
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    return avg.toStringAsFixed(2).replaceAll('.', ',');
  }

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
    isLoading = true; loginError = '';
    notifyListeners();

    _api = ApiService(serverUrl: serverUrl);
    final result = await _api!.login(identifiant, mdp);

    if (result['ok'] == true) {
      _token   = result['token'] as String;
      userName = result['user']  as String? ?? identifiant;
      await _storage.saveToken(_token!);
      await _storage.saveUserName(userName);
      isLoggedIn = true;
      await fetchData();
      if (activeMode) _startPolling();
    } else {
      loginError = result['error'] as String? ?? 'Connexion échouée.';
    }
    isLoading = false;
    notifyListeners();
  }

  // ── Restore session silencieuse au démarrage ───────────────────────────────
  Future<void> _tryRestoreSession() async {
    final result = await _api!.fetchData(_token!);
    if (result['ok'] == true) {
      _parseDataResult(result);
      isLoggedIn = true;
      if (activeMode) _startPolling();
    } else {
      // Token expiré
      _token = null;
      await _storage.deleteToken();
    }
  }

  // ── Fetch data ─────────────────────────────────────────────────────────────
  Future<void> fetchData() async {
    if (_token == null || _api == null) return;
    dataLoading = true;
    notifyListeners();

    final result = await _api!.fetchData(_token!);
    if (result['ok'] == true) {
      _parseDataResult(result);
    } else {
      // Session expirée côté serveur
      isLoggedIn = false;
      _token = null;
      await _storage.deleteToken();
    }
    dataLoading = false;
    notifyListeners();
  }

  void _parseDataResult(Map<String, dynamic> result) {
    notes = (result['notes'] as List? ?? [])
        .map((e) => NoteMatiere.fromJson(e as Map<String, dynamic>))
        .toList();
    devoirs = (result['devoirs'] as List? ?? [])
        .map((e) => Devoir.fromJson(e as Map<String, dynamic>))
        .toList();

    // Notifs locales
    for (final n in (result['notifications'] as List? ?? [])) {
      final notif = ServerNotif.fromJson(n as Map<String, dynamic>);
      if (notif.type == 'note'   && notifNotes)   _notifs.show(notif.title, notif.body);
      if (notif.type == 'devoir' && notifDevoirs) _notifs.show(notif.title, notif.body);
    }
  }

  // ── Détail devoir ──────────────────────────────────────────────────────────
  Future<DevoirSections?> fetchDevoirDetail(String url) async {
    if (_token == null || _api == null) return null;
    return _api!.fetchDevoirDetail(_token!, url);
  }

  // ── Polling 30s ───────────────────────────────────────────────────────────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchData());
  }
  void stopPolling()  { _pollTimer?.cancel(); _pollTimer = null; }
  void startPolling() { if (isLoggedIn) _startPolling(); }

  // ── Prefs setters ──────────────────────────────────────────────────────────
  Future<void> setNotifNotes(bool v)   async { notifNotes   = v; await _storage.setNotifNotes(v);   notifyListeners(); }
  Future<void> setNotifDevoirs(bool v) async { notifDevoirs = v; await _storage.setNotifDevoirs(v); notifyListeners(); }
  Future<void> setActiveMode(bool v)   async {
    activeMode = v; await _storage.setActiveMode(v);
    if (v) _startPolling(); else stopPolling();
    notifyListeners();
  }
  Future<void> setPrefsSet(bool v)     async { prefsSet = v; await _storage.setPrefsSet(v); notifyListeners(); }
  Future<void> setServerUrl(String v)  async { serverUrl = v; await _storage.saveServerUrl(v); notifyListeners(); }

  // ── Toggle devoir fait ─────────────────────────────────────────────────────
  void toggleDevoir(String id) {
    final idx = devoirs.indexWhere((d) => d.id == id);
    if (idx != -1) { devoirs[idx].fait = !devoirs[idx].fait; notifyListeners(); }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    if (_token != null && _api != null) await _api!.logout(_token!);
    stopPolling();
    _token = null; isLoggedIn = false; prefsSet = false;
    notes = []; devoirs = []; userName = '';
    await _storage.clearAll();
    notifyListeners();
  }
}
