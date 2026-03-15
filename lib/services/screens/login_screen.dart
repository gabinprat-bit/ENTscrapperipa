import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _idCtrl     = TextEditingController();
  final _pwCtrl     = TextEditingController();
  final _serverCtrl = TextEditingController();
  bool _showServer  = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      _serverCtrl.text = state.serverUrl;
      if (state.serverUrl.isEmpty) setState(() => _showServer = true);
      _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _serverCtrl.dispose();
    super.dispose();
  }

  void _doLogin() {
    final state = context.read<AppState>();
    if (_serverCtrl.text.isNotEmpty) state.setServerUrl(_serverCtrl.text.trim());
    state.login(_idCtrl.text.trim(), _pwCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Titre animé
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF56CCF2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(b),
                      child: Text('Mon ENT',
                          style: GoogleFonts.sora(
                            fontSize: 46, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: -2,
                          )),
                    ),
                    const SizedBox(height: 6),
                    Text('Collège Maurice Constantin Weyer · Cusset',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12, letterSpacing: 0.5,
                        )),
                  ]),
                ),
              ),

              const SizedBox(height: 40),

              // Carte login
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02040E).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF56CCF2).withOpacity(0.18)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, offset: const Offset(0, 20))],
                    ),
                    child: Column(children: [

                      // URL Serveur
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showServer
                          ? _field('URL DU SERVEUR', 'https://mon-serveur.com',
                              _serverCtrl, TextInputType.url, false)
                          : const SizedBox.shrink(),
                      ),

                      if (_showServer) const SizedBox(height: 12),

                      // Identifiant
                      _field('IDENTIFIANT EDUCONNECT', 'g.nom00',
                          _idCtrl, TextInputType.emailAddress, false),
                      const SizedBox(height: 12),

                      // Mot de passe
                      _field('MOT DE PASSE', '••••••••••',
                          _pwCtrl, TextInputType.visiblePassword, true),
                      const SizedBox(height: 14),

                      // Bouton
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A3D7A), Color(0xFF2F80ED), Color(0xFF56CCF2)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: const Color(0xFF2F80ED).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
                          ),
                          child: ElevatedButton(
                            onPressed: (state.isLoading || _idCtrl.text.isEmpty || _pwCtrl.text.isEmpty || _serverCtrl.text.isEmpty) ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
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
                            Expanded(child: Text(state.loginError,
                              style: const TextStyle(color: Color(0xFFFF7070), fontSize: 13))),
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Config serveur
              TextButton.icon(
                onPressed: () => setState(() => _showServer = !_showServer),
                icon: const Icon(Icons.dns_rounded, size: 14, color: Colors.white30),
                label: Text(
                  _showServer ? 'Masquer la config serveur' : 'Configurer le serveur',
                  style: const TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock_rounded, size: 12, color: Colors.white24),
                const SizedBox(width: 5),
                Text('Connexion chiffrée · données locales uniquement',
                    style: const TextStyle(color: Colors.white24, fontSize: 11)),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  Widget _field(String label, String hint, TextEditingController ctrl,
      TextInputType type, bool obscure) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.0)),
      const SizedBox(height: 7),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 15),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.09)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.09)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF56CCF2), width: 1.5),
          ),
        ),
      ),
    ]);
  }
}
