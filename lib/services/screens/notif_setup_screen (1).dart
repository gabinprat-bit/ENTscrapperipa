import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';

class NotifSetupScreen extends StatelessWidget {
  const NotifSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(children: [
            const SizedBox(height: 40),
            Text('Notifications', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('Choisis ce que tu veux surveiller', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 28),

            // Carte notifs
            _GlassCard(children: [
              _NotifRow(
                icon: '📊',
                iconColor: const Color(0xFF2F80ED),
                title: 'Nouvelles notes',
                subtitle: 'Alerte à chaque nouvelle note',
                value: state.notifNotes,
                onChanged: state.setNotifNotes,
              ),
              const Divider(color: Colors.white10, height: 1),
              _NotifRow(
                icon: '📚',
                iconColor: const Color(0xFF6FCF97),
                title: 'Nouveaux devoirs',
                subtitle: 'Alerte quand un devoir est ajouté',
                value: state.notifDevoirs,
                onChanged: state.setNotifDevoirs,
              ),
            ]),
            const SizedBox(height: 10),

            // Mode actif
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6FCF97).withOpacity(0.2)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('⚡ Mode actif', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF6FCF97))),
                  const SizedBox(height: 2),
                  Text('Vérification toutes les 30s', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                ])),
                Switch(
                  value: state.activeMode,
                  onChanged: state.setActiveMode,
                  activeColor: const Color(0xFF6FCF97),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // Bouton
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1A5EB8), Color(0xFF2F80ED)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFF2F80ED).withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton(
                  onPressed: () => state.setPrefsSet(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Accéder à l\'app →', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

class _GlassCard extends StatelessWidget {
  final List<Widget> children;
  const _GlassCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.055),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.09)),
    ),
    child: Column(children: children),
  );
}

class _NotifRow extends StatelessWidget {
  final String icon, title, subtitle;
  final Color iconColor;
  final bool value;
  final Future<void> Function(bool) onChanged;
  const _NotifRow({required this.icon, required this.iconColor, required this.title,
      required this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 16))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6FCF97)),
    ]),
  );
}
