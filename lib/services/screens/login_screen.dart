import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _urlCtrl = TextEditingController();
  final _idCtrl  = TextEditingController();
  final _pwCtrl  = TextEditingController();
  bool _permanent = false;  // <-- NOUVEAU
  
  late AnimationController _ac;
  late Animation<double> _fade;
  late Animation<Offset>  _slide;

  @override
  void initState() {
    super.initState();
    _ac    = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.serverUrl.isNotEmpty) _urlCtrl.text = state.serverUrl;
      _ac.forward();
    });
  }

  @override
  void dispose() { _ac.dispose(); _urlCtrl.dispose(); _idCtrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  void _login() {
    final state = context.read<AppState>();
    if (_urlCtrl.text.isNotEmpty) state.setServerUrl(_urlCtrl.text.trim());
    state.login(_idCtrl.text.trim(), _pwCtrl.text.trim(), makePermanent: _permanent);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 60),
            FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: Column(children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Colors.white, Color(0xFF56CCF2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ).createShader(b),
                child: Text('Mon ENT', style: GoogleFonts.sora(fontSize: 46, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -2)),
              ),
              const SizedBox(height: 6),
              Text('Collège Maurice Constantin Weyer · Cusset',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, letterSpacing: 0.5)),
            ]))),
            const SizedBox(height: 40),
            FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: _card(state))),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_rounded, size: 11, color: Colors.white24),
              const SizedBox(width: 5),
              Text('Credentials chiffrés · données locales', style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ]),
            const SizedBox(height: 40),
          ]),
        ),
      );
    });
  }

  Widget _card(AppState state) {
    final canLogin = !state.isLoading && _urlCtrl.text.isNotEmpty && _idCtrl.text.isNotEmpty && _pwCtrl.text.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF02040E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF56CCF2).withOpacity(0.18)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(children: [
        _field('URL DU SERVEUR', 'https://mon-serveur.com', _urlCtrl, TextInputType.url, false),
        const SizedBox(height: 12),
        _field('IDENTIFIANT EDUCONNECT', 'g.nom00', _idCtrl, TextInputType.emailAddress, false),
        const SizedBox(height: 12),
        _field('MOT DE PASSE', '••••••••••', _pwCtrl, TextInputType.visiblePassword, true),
        const SizedBox(height: 8),
        
        // ── Compte permanent (NOUVEAU) ──
        Row(children: [
          Checkbox(
            value: _permanent,
            onChanged: (v) => setState(() => _permanent = v ?? false),
            activeColor: const Color(0xFF6FCF97),
            side: const BorderSide(color: Colors.white38),
          ),
          const Text('Compte permanent', 
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          TextButton(
            onPressed: () => _showSwitchInfo(),
            child: const Text('Changer de compte ?', 
                style: TextStyle(color: Color(0xFF56CCF2), fontSize: 12)),
          ),
        ]),
        
        const SizedBox(height: 8),

        // Bouton
        SizedBox(width: double.infinity, height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0A3D7A), Color(0xFF2F80ED), Color(0xFF56CCF2)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFF2F80ED).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: ElevatedButton(
              onPressed: canLogin ? _login : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: state.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Se connecter', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),

        // Erreur
        if (state.loginError.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEB5757).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEB5757).withOpacity(0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.warning_rounded, color: Color(0xFFEB5757), size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(state.loginError, style: const TextStyle(color: Color(0xFFFF7070), fontSize: 13))),
            ]),
          ),
        ],
      ]),
    );
  }
  
  void _showSwitchInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF060A18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Changer de compte', style: TextStyle(color: Colors.white)),
        content: Text(
          'Pour changer de compte, connecte-toi d\'abord, puis utilise le bouton "Changer de compte" dans les paramètres.\n\n'
          'Le compte permanent reste associé à ton appareil même après fermeture de l\'app.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF56CCF2))),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl, TextInputType type, bool obscure) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
      const SizedBox(height: 7),
      TextField(
        controller: ctrl, obscureText: obscure, keyboardType: type,
        autocorrect: false, enableSuggestions: false, textCapitalization: TextCapitalization.none,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 15),
          filled: true, fillColor: Colors.white.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.09))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.09))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF56CCF2), width: 1.5)),
        ),
      ),
    ]);
  }
}
