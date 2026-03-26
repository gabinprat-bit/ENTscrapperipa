import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceAuthService {
  static final DeviceAuthService _instance = DeviceAuthService._internal();
  factory DeviceAuthService() => _instance;
  DeviceAuthService._internal();

  String? _deviceId;

  /// Récupère ou génère un ID unique pour l'appareil
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    
    if (_deviceId == null) {
      final random = Random.secure();
      _deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';
      await prefs.setString('device_id', _deviceId!);
    }
    
    return _deviceId!;
  }

  /// Sauvegarde le compte permanent
  Future<void> setPermanentAccount(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('permanent_user_id', userId);
    await prefs.setString('permanent_token', token);
    await prefs.setBool('permanent_account_enabled', true);
  }

  /// Récupère le compte permanent
  Future<Map<String, String?>?> getPermanentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('permanent_account_enabled') ?? false;
    if (!enabled) return null;
    
    return {
      'userId': prefs.getString('permanent_user_id'),
      'token': prefs.getString('permanent_token'),
    };
  }

  /// Supprime le compte permanent
  Future<void> clearPermanentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('permanent_user_id');
    await prefs.remove('permanent_token');
    await prefs.setBool('permanent_account_enabled', false);
  }

  /// Vérifie si le compte actuel est permanent
  Future<bool> isPermanentAccount(String userId) async {
    final permanent = await getPermanentAccount();
    return permanent != null && permanent['userId'] == userId;
  }

  /// Associe un compte à l'appareil côté serveur
  Future<bool> associateAccountWithDevice(String serverUrl, String token, String userId) async {
    try {
      final deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse('$serverUrl/api/associate_device'),
        headers: {'Content-Type': 'application/json', 'X-Token': token},
        body: jsonEncode({'device_id': deviceId, 'user_id': userId}),
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(response.body);
      return data['ok'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Dissocie un compte
  Future<bool> dissociateAccount(String serverUrl, String token) async {
    try {
      final deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse('$serverUrl/api/dissociate_device'),
        headers: {'Content-Type': 'application/json', 'X-Token': token},
        body: jsonEncode({'device_id': deviceId}),
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(response.body);
      return data['ok'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Envoie l'ID appareil lors du login
  Future<Map<String, dynamic>> loginWithDevice(String serverUrl, String identifiant, String mdp) async {
    try {
      final deviceId = await getDeviceId();
      final response = await http.post(
        Uri.parse('$serverUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifiant': identifiant,
          'mdp': mdp,
          'device_id': deviceId,
        }),
      ).timeout(const Duration(seconds: 45));
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'ok': false, 'error': 'Erreur réseau : $e'};
    }
  }
}
