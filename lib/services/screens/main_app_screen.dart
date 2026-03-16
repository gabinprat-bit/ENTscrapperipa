import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../../models/models.dart';
import 'widgets/devoir_detail_sheet.dart';

const _palette = [
  Color(0xFF2F80ED), Color(0xFF27AE60), Color(0xFFF2994A), Color(0xFFEB5757),
  Color(0xFF9B51E0), Color(0xFF56CCF2), Color(0xFFF2C94C), Color(0xFF219653),
];
Color matiereColor(String name) => _palette[name.hashCode.abs() % _palette.length];

// ══════════════════════════════════════════════════════════════════════════════
//  MAIN APP SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _Header(tab: _tab, onTab: (t) => setState(() => _tab = t)),
      Expanded(child: _tab == 0 ? const _NotesTab() : const _DevoirsTab()),
    ]);
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _Header({required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return Container(
        color: Colors.black.withOpacity(.72),
        child: SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(
                  style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  children: [
                    const TextSpan(text: 'Bonjour, '),
                    TextSpan(text: state.userName, style: const TextStyle(color: Color(0xFF56CCF2))),
                    const TextSpan(text: ' 👋'),
                  ],
                )),
                const SizedBox(height: 5),
                _StatusPill(active: state.activeMode),
              ])),
              Row(children: [
                _HBtn(Icons.refresh_rounded, () => context.read<AppState>().fetchData()),
                const SizedBox(width: 8),
                _HBtn(Icons.settings_rounded, () => _openSettings(context, state)),
                const SizedBox(width: 8),
                _HBtn(Icons.power_settings_new_rounded, () => _confirmLogout(context, state)),
              ]),
            ]),
            const SizedBox(height: 12),
            _Tabs(current: tab, onTap: onTab),
            const SizedBox(height: 4),
          ]),
        )),
      );
    });
  }

  void _openSettings(BuildContext ctx, AppState state) {
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(value: state, child: const _SettingsSheet()));
  }

  void _confirmLogout(BuildContext ctx, AppState state) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF060A18),
      title: const Text('Se déconnecter ?', style: TextStyle(color: Colors.white)),
      content: const Text('Tu devras te reconnecter.', style: TextStyle(color: Colors.white60)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: Colors.white54))),
        TextButton(onPressed: () { Navigator.pop(ctx); state.logout(); }, child: const Text('Déconnecter', style: TextStyle(color: Color(0xFFEB5757)))),
      ],
    ));
  }
}

class _StatusPill extends StatelessWidget {
  final bool active;
  const _StatusPill({required this.active});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF27AE60).withOpacity(.12) : Colors.white.withOpacity(.05),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: active ? const Color(0xFF6FCF97).withOpacity(.25) : Colors.transparent),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle,
          color: active ? const Color(0xFF6FCF97) : Colors.white30)),
      const SizedBox(width: 6),
      Text(active ? 'Mode actif · 30s' : 'Mode manuel',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF6FCF97) : Colors.white30)),
    ]),
  );
}

class _HBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 34, height: 34,
      decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
      child: Icon(icon, color: Colors.white54, size: 16)),
  );
}

class _Tabs extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _Tabs({required this.current, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      _Tab('📊  Notes',   0, current, onTap),
      _Tab('📚  Devoirs', 1, current, onTap),
    ]),
  );
}

class _Tab extends StatelessWidget {
  final String label;
  final int idx, current;
  final ValueChanged<int> onTap;
  const _Tab(this.label, this.idx, this.current, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: () => onTap(idx),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: current == idx ? Colors.white.withOpacity(.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: current == idx ? Colors.white : Colors.white54)),
    ),
  ));
}

// ══════════════════════════════════════════════════════════════════════════════
//  NOTES TAB
// ══════════════════════════════════════════════════════════════════════════════

class _NotesTab extends StatefulWidget {
  const _NotesTab();
  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      if (state.dataLoading && state.notes.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2F80ED), strokeWidth: 2));
      }
      if (state.notes.isEmpty) return const _Empty('📊', 'Aucune note disponible');

      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        children: [
          // ── Moyenne générale ──
          if (state.moyenneGenerale != null) _MoyenneBanner(moy: state.moyenneGenerale!, count: state.notes.length),
          const SizedBox(height: 4),
          // ── Notes par matière ──
          ...state.notes.map((m) => _NoteCard(
            matiere: m,
            expanded: _expanded.contains(m.matiere),
            onTap: () => setState(() {
              if (_expanded.contains(m.matiere)) _expanded.remove(m.matiere);
              else _expanded.add(m.matiere);
            }),
          )),
        ],
      );
    });
  }
}

// ── Moyenne générale banner ───────────────────────────────────────────────────

class _MoyenneBanner extends StatelessWidget {
  final String moy;
  final int count;
  const _MoyenneBanner({required this.moy, required this.count});

  Color get _color {
    final n = double.tryParse(moy.replaceAll(',', '.'));
    if (n == null) return Colors.white;
    if (n >= 14) return const Color(0xFF6FCF97);
    if (n >= 10) return const Color(0xFFF2994A);
    return const Color(0xFFEB5757);
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [const Color(0xFF2F80ED).withOpacity(.12), const Color(0xFF56CCF2).withOpacity(.08)]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF56CCF2).withOpacity(.2)),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MOYENNE GÉNÉRALE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(.5), letterSpacing: .8)),
        const SizedBox(height: 2),
        Text('$count matière(s)', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.3))),
      ])),
      Text(moy, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: _color,
          fontFeatures: const [FontFeature.tabularFigures()])),
    ]),
  );
}

// ── Note card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final NoteMatiere matiere;
  final bool expanded;
  final VoidCallback onTap;
  const _NoteCard({required this.matiere, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final clr = matiereColor(matiere.matiere);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF02040E).withOpacity(.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: onTap,
          child: Container(color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(width: 3, height: 38, decoration: BoxDecoration(color: clr, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(matiere.matiere, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${matiere.evals.length} évaluation(s)', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.5))),
              ])),
              Text(matiere.moyenne.isEmpty ? '—' : matiere.moyenne,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: matiere.moyenneColor,
                      fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(width: 6),
              AnimatedRotation(turns: expanded ? .25 : 0, duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 18)),
            ]),
          ),
        ),
        if (expanded) ...[
          Divider(color: Colors.white.withOpacity(.07), height: 1),
          ...matiere.evals.map((e) => _EvalRow(eval: e, color: clr)),
        ],
      ]),
    );
  }
}

class _EvalRow extends StatelessWidget {
  final NoteEval eval;
  final Color color;
  const _EvalRow({required this.eval, required this.color});
  @override
  Widget build(BuildContext context) {
    final ap = eval.appreciation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.04)))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eval.titre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 2),
          Text('${eval.date} · coef. ${eval.coefficient.toStringAsFixed(eval.coefficient == eval.coefficient.roundToDouble() ? 0 : 1)}',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.45))),
          const SizedBox(height: 3),
          Text(ap.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ap.color)),
          Text(ap.tip, style: TextStyle(fontSize: 10, color: ap.color.withOpacity(.7))),
        ])),
        const SizedBox(width: 12),
        RichText(text: TextSpan(children: [
          TextSpan(text: eval.valeurStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color,
              fontFeatures: const [FontFeature.tabularFigures()])),
          TextSpan(text: '/${eval.baremeStr}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DEVOIRS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _DevoirsTab extends StatelessWidget {
  const _DevoirsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      if (state.dataLoading && state.devoirs.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2F80ED), strokeWidth: 2));
      }
      if (state.devoirs.isEmpty) return const _Empty('✅', 'Aucun devoir à venir !');

      final Map<String, List<Devoir>> grouped = {};
      for (final d in state.devoirs) { grouped.putIfAbsent(d.pourLe, () => []).add(d); }

      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        children: grouped.entries.expand((entry) => [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 10),
            child: Text('Pour ${entry.key}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white30, letterSpacing: .8)),
          ),
          ...entry.value.map((d) => _DevoirCard(
            devoir: d,
            onTap: () => showModalBottomSheet(context: ctx, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChangeNotifierProvider.value(value: state, child: DevoirDetailSheet(devoir: d))),
          )),
        ]).toList(),
      );
    });
  }
}

class _DevoirCard extends StatelessWidget {
  final Devoir devoir;
  final VoidCallback onTap;
  const _DevoirCard({required this.devoir, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final clr = matiereColor(devoir.matiere);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: devoir.fait ? const Color(0xFF6FCF97).withOpacity(.05) : const Color(0xFF02040E).withOpacity(.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: devoir.fait ? const Color(0xFF6FCF97).withOpacity(.15) : Colors.white.withOpacity(.09)),
        ),
        child: Row(children: [
          Container(width: 3, height: 38, decoration: BoxDecoration(
              color: devoir.fait ? const Color(0xFF6FCF97) : clr, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.read<AppState>().toggleDevoir(devoir.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: devoir.fait ? const Color(0xFF6FCF97) : Colors.transparent,
                border: Border.all(color: devoir.fait ? const Color(0xFF6FCF97) : Colors.white24, width: 2),
              ),
              child: devoir.fait ? const Icon(Icons.check_rounded, size: 14, color: Colors.black) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(devoir.matiere, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: clr)),
            Text(devoir.type, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(devoir.pourLe.split(' ').skip(1).take(2).join(' '),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF56CCF2))),
            Text(devoir.donneLe, style: const TextStyle(fontSize: 10, color: Colors.white30)),
          ]),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 16),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SETTINGS SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF060A18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 22),
          Text('Paramètres', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 20),

          _SLbl('NOTIFICATIONS'),
          _STile('Nouvelles notes',  '📊', state.notifNotes,   state.setNotifNotes),
          _STile('Nouveaux devoirs', '📚', state.notifDevoirs, state.setNotifDevoirs),
          const SizedBox(height: 16),

          _SLbl('COMPORTEMENT'),
          _STile('Mode actif (30s)', '⚡', state.activeMode, state.setActiveMode),
          const SizedBox(height: 16),

          // ── Bouton Admin ──
          _SLbl('ADMINISTRATION'),
          GestureDetector(
            onTap: () => _showAdminDialog(context, state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2994A).withOpacity(.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF2994A).withOpacity(.25)),
              ),
              child: Row(children: [
                const Text('🔐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Panneau Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(
                    state.serverUrl.isNotEmpty ? 'Serveur : ${state.serverUrl}' : '⚠️ Aucun serveur configuré',
                    style: TextStyle(fontSize: 11, color: state.serverUrl.isNotEmpty ? Colors.white38 : const Color(0xFFF2994A)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ])),
                const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ── Déconnexion ──
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); state.logout(); },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEB5757).withOpacity(.15),
              foregroundColor: const Color(0xFFEB5757),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFEB5757), width: .5)),
            ),
          )),
          const SizedBox(height: 10),
          Center(child: Text('Version 1.0 · Polling 30s',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.25)))),
        ]),
      )),
    ));
  }

  void _showAdminDialog(BuildContext context, AppState state) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF060A18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Text('🔐 ', style: TextStyle(fontSize: 20)),
          Text('Accès Admin', style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Entre le code admin pour accéder aux paramètres serveur.',
              style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: codeCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true, fillColor: Colors.white.withOpacity(.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF2994A))),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text == 'root1234') {
                Navigator.pop(context);
                _showAdminPanel(context, state);
              } else {
                codeCtrl.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code incorrect ❌'),
                    backgroundColor: Color(0xFFEB5757),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2994A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showAdminPanel(BuildContext context, AppState state) {
    final urlCtrl = TextEditingController(text: state.serverUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: _AdminPanel(urlCtrl: urlCtrl),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ADMIN PANEL
// ══════════════════════════════════════════════════════════════════════════════

class _AdminPanel extends StatefulWidget {
  final TextEditingController urlCtrl;
  const _AdminPanel({required this.urlCtrl});
  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF060A18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 22),

          // Titre
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF2994A).withOpacity(.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF2994A).withOpacity(.3)),
              ),
              child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFF2994A), letterSpacing: 1.5)),
            ),
            const SizedBox(width: 12),
            Text('Configuration serveur', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
          const SizedBox(height: 6),
          Text('Cette URL est partagée pour tous les utilisateurs.',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.4))),
          const SizedBox(height: 20),

          // Champ URL
          const Text('URL DU SERVEUR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white30, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          TextField(
            controller: widget.urlCtrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: (_) { if (_saved) setState(() => _saved = false); },
            decoration: InputDecoration(
              hintText: 'http://51.75.118.5:20119',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              filled: true, fillColor: Colors.white.withOpacity(.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFF2994A), width: 1.5)),
              suffixIcon: widget.urlCtrl.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                    onPressed: () { widget.urlCtrl.clear(); setState(() {}); })
                : null,
            ),
          ),
          const SizedBox(height: 8),
          // Statut URL actuelle
          if (state.serverUrl.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6FCF97).withOpacity(.2)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF6FCF97), size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text('Actuel : ${state.serverUrl}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6FCF97)),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2994A).withOpacity(.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF2994A).withOpacity(.2)),
              ),
              child: const Row(children: [
                Icon(Icons.warning_rounded, color: Color(0xFFF2994A), size: 14),
                SizedBox(width: 8),
                Text('Aucun serveur configuré — les utilisateurs ne peuvent pas se connecter.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFF2994A))),
              ]),
            ),
          const SizedBox(height: 20),

          // Boutons
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () async {
                final url = widget.urlCtrl.text.trim();
                if (url.isEmpty) return;
                await state.setServerUrl(url);
                setState(() => _saved = true);
                FocusScope.of(context).unfocus();
              },
              icon: Icon(_saved ? Icons.check_rounded : Icons.save_rounded, size: 18),
              label: Text(_saved ? 'Sauvegardé ✅' : 'Sauvegarder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _saved ? const Color(0xFF27AE60) : const Color(0xFFF2994A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(.07),
                foregroundColor: Colors.white60,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.white12)),
              ),
              child: const Text('Fermer'),
            )),
          ]),
          const SizedBox(height: 8),
          Center(child: Text('Code admin requis pour modifier · root1234',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(.2)))),
        ]),
      )),
    ));
  }
}

class _SLbl extends StatelessWidget {
  final String t;
  const _SLbl(this.t);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white30, letterSpacing: 1.0)),
  );
}
class _STile extends StatelessWidget {
  final String label, icon;
  final bool value;
  final Future<void> Function(bool) onChanged;
  const _STile(this.label, this.icon, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 18)), const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6FCF97)),
    ]),
  );
}

class _Empty extends StatelessWidget {
  final String icon, text;
  const _Empty(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 40)),
    const SizedBox(height: 14),
    Text(text, style: const TextStyle(color: Colors.white54, fontSize: 14)),
  ]));
}
