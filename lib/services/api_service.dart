import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String serverUrl;
  final Duration timeout;

  ApiService({required this.serverUrl})
      : timeout = const Duration(seconds: 45); // Augmenté pour 5G

  String get _base => serverUrl.endsWith('/')
      ? serverUrl.substring(0, serverUrl.length - 1)
      : serverUrl;

  // ── Login avec support 5G et appareil ──────────────────────────────────────
  Future<Map<String, dynamic>> login(String identifiant, String mdp, {String? deviceId}) async {
    try {
      final body = {'identifiant': identifiant, 'mdp': mdp};
      if (deviceId != null) body['device_id'] = deviceId;
      
      final resp = await http
          .post(
            Uri.parse('$_base/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      
      if (data['ok'] == true && data['already_associated'] == true) {
        return {
          'ok': false,
          'error': 'Ce compte est déjà associé à un autre appareil. Utilise le panneau admin pour dissocier.',
          'requires_admin': true,
        };
      }
      
      return data;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur réseau : Vérifie ta connexion 5G/WiFi - $e'};
    }
  }

  // ── Login avec force (admin) ───────────────────────────────────────────────
  Future<Map<String, dynamic>> forceLogin(String identifiant, String mdp, {String? deviceId}) async {
    try {
      final body = {'identifiant': identifiant, 'mdp': mdp};
      if (deviceId != null) body['force_device_id'] = deviceId;
      
      final resp = await http
          .post(
            Uri.parse('$_base/api/force_login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur réseau : $e'};
    }
  }

  // ── Data avec retry pour 5G ────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchData(String token, {int retries = 2}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final resp = await http
            .get(
              Uri.parse('$_base/api/data'),
              headers: {'X-Token': token},
            )
            .timeout(timeout);
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        if (i == retries) {
          return {'ok': false, 'error': 'Erreur réseau après $retries tentatives : $e'};
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return {'ok': false, 'error': 'Erreur réseau'};
  }

  // ── Détail devoir ──────────────────────────────────────────────────────────
  Future<String> fetchDevoirDetail(String token, String url) async {
    try {
      final encoded = Uri.encodeComponent(url);
      final resp = await http
          .get(
            Uri.parse('$_base/api/devoir_detail?url=$encoded'),
            headers: {'X-Token': token},
          )
          .timeout(timeout);
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['description'] as String? ?? 'Aucune description.';
    } catch (e) {
      return 'Impossible de charger.';
    }
  }

  // ── Logout avec dissociation ───────────────────────────────────────────────
  Future<void> logout(String token) async {
    try {
      await http
          .post(
            Uri.parse('$_base/api/logout'),
            headers: {'X-Token': token},
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ── Health avec retry ──────────────────────────────────────────────────────
  Future<bool> checkHealth({int retries = 2}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final resp = await http
            .get(Uri.parse('$_base/health'))
            .timeout(const Duration(seconds: 12));
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['status'] == 'ok';
      } catch (_) {
        if (i == retries) return false;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUTES ADMIN
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> adminListAccounts(String adminToken) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/admin/accounts'),
            headers: {'X-Admin-Token': adminToken},
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur : $e'};
    }
  }

  Future<Map<String, dynamic>> adminDissociateAccount(String adminToken, String userId) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/admin/dissociate'),
            headers: {'Content-Type': 'application/json', 'X-Admin-Token': adminToken},
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur : $e'};
    }
  }

  Future<Map<String, dynamic>> adminForceAssociate(String adminToken, String userId, String deviceId) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/admin/force_associate'),
            headers: {'Content-Type': 'application/json', 'X-Admin-Token': adminToken},
            body: jsonEncode({'user_id': userId, 'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur : $e'};
    }
  }

  Future<Map<String, dynamic>> adminGetLogs(String adminToken, {int lines = 50}) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/admin/logs?lines=$lines'),
            headers: {'X-Admin-Token': adminToken},
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur : $e'};
    }
  }

  Future<Map<String, dynamic>> adminGetStats(String adminToken) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/admin/stats'),
            headers: {'X-Admin-Token': adminToken},
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur : $e'};
    }
  }

  Future<Map<String, dynamic>> adminForceRefresh(String adminToken, String userId) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/admin/force_refresh'),
            headers: {'Content-Type': 'application/json', 'X-Admin-Token': adminToken},
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 30));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur : $e'};
    }
  }
}
