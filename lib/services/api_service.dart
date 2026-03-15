import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String serverUrl;
  final Duration timeout;

  ApiService({required this.serverUrl})
      : timeout = const Duration(seconds: 30);

  String get _base => serverUrl.endsWith('/')
      ? serverUrl.substring(0, serverUrl.length - 1)
      : serverUrl;

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String identifiant, String mdp) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'identifiant': identifiant, 'mdp': mdp}),
          )
          .timeout(const Duration(seconds: 35));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Serveur inaccessible : $e'};
    }
  }

  // ── Data (notes + devoirs + notifs) ────────────────────────────────────────
  Future<Map<String, dynamic>> fetchData(String token) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/data'),
            headers: {'X-Token': token},
          )
          .timeout(timeout);
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Erreur réseau : $e'};
    }
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

  // ── Logout ─────────────────────────────────────────────────────────────────
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

  // ── Health ─────────────────────────────────────────────────────────────────
  Future<bool> checkHealth() async {
    try {
      final resp = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 8));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
