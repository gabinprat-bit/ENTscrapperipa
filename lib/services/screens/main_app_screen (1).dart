import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../widgets/devoir_detail_sheet.dart';

// ── Palette de couleurs par matière ─────────────────────────────────────────
const _palette = [
  Color(0xFF2F80ED), Color(0xFF27AE60), Color(0xFFF2994A), Color(0xFFEB5757),
  Color(0xFF9B51E0), Color(0xFF56CCF2), Color(0xFFF2C94C), Color(0xFF219653),
];
Color matiereColor(String name) => _palette[name.hashCode.abs() % _palette.length];

// ═══════════════════════════════════════════════════════════════════════════
// MAIN APP SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return Column(children: [
        // Header
        _Header(tab: _tab, onTabChanged: (t) => setState(() => _tab = t)),
        // Contenu
        Expanded(child: _tab == 0 ? const NotesTab() : const DevoirsTab()),
      ]);
    });
  }
}

// ── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTabChanged;
  const _Header({required this.tab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return Container(
        color: Colors.black.withOpacity(0.7),
        child: ClipRect(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: const Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(children: [
                  // Top row
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: state.activeMode ? const Color(0xFF27AE60).withOpacity(0.12) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: state.activeMode ? const Color(0xFF6FCF97).withOpacity(0.25) : Colors.transparent),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: state.activeMode ? const Color(0xFF6FCF97) : Colors.white30,
                            )),
                          const SizedBox(width: 6),
                          Text(
                            state.activeMode ? 'Mode actif · 30s' : 'Mode manuel',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: state.activeMode ? const Color(0xFF6FCF97) : Colors.white30,
                            ),
                          ),
                        ]),
                      ),
                    ])),
                    Row(children: [
                      _HdrBtn(icon: Icons.refresh_rounded,
                          onTap: () => context.read<AppState>().fetchData()),
                      const SizedBox(width: 8),
                      _HdrBtn(icon: Icons.settings_rounded,
                          onTap: () => showModalBottomSheet(context: ctx,
                              isScrollControlled: true, backgroundColor: Colors.transparent,
                              builder: (_) => ChangeNotifierProvider.value(value: state, child: const SettingsSheet()))),
                    ]),
                  ]),
                  const SizedBox(height: 12),
                  // Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      _TabBtn('📊  Notes',   0, tab, onTabChanged),
                      _TabBtn('📚  Devoirs', 1, tab, onTabChanged),
                    ]),
                  ),
                  const SizedBox(height: 4),
                ]),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _HdrBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HdrBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Icon(icon, color: Colors.white54, size: 16),
    ),
  );
}

class _TabBtn extends StatelessWidget {
  final String label;
  final int idx, current;
  final ValueChanged<int> onTap;
  const _TabBtn(this.label, this.idx, this.current, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: current == idx ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: current == idx ? Colors.white : Colors.white45,
        )),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTES TAB
// ═══════════════════════════════════════════════════════════════════════════

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});
  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      if (state.dataLoading && state.notes.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2F80ED), strokeWidth: 2));
      }
      if (state.notes.isEmpty) {
        return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('📊', style: TextStyle(fontSize: 40)),
          SizedBox(height: 14),
          Text('Aucune note disponible', style: TextStyle(color: Colors.white54, fontSize: 14)),
        ]));
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        itemCount: state.notes.length,
        itemBuilder: (_, i) {
          final m = state.notes[i];
          final expanded = _expanded.contains(m.matiere);
          return _NoteCard(
            matiere: m, expanded: expanded,
            onTap: () => setState(() {
              if (expanded) _expanded.remove(m.matiere); else _expanded.add(m.matiere);
            }),
          );
        },
      );
    });
  }
}

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
        color: const Color(0xFF02040E).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(width: 3, height: 38, decoration: BoxDecoration(color: clr, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(matiere.matiere, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${matiere.evals.length} évaluation(s)',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
              ])),
              Text(matiere.moyenne.isEmpty ? '—' : matiere.moyenne,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: matiere.moyenneColor,
                      fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 18),
              ),
            ]),
          ),
        ),
        if (expanded) ...[
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04)))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eval.titre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 2),
        Text('${eval.date} · coef. ${eval.coefficient.toStringAsFixed(eval.coefficient == eval.coefficient.roundToDouble() ? 0 : 1)} · ${eval.appreciation}',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.45))),
      ])),
      RichText(text: TextSpan(
        children: [
          TextSpan(text: eval.valeurStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color,
              fontFeatures: const [FontFeature.tabularFigures()])),
          TextSpan(text: '/${eval.baremeStr}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      )),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// DEVOIRS TAB
// ═══════════════════════════════════════════════════════════════════════════

class DevoirsTab extends StatelessWidget {
  const DevoirsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      if (state.dataLoading && state.devoirs.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF2F80ED), strokeWidth: 2));
      }
      if (state.devoirs.isEmpty) {
        return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('✅', style: TextStyle(fontSize: 40)),
          SizedBox(height: 14),
          Text('Aucun devoir à venir !', style: TextStyle(color: Colors.white54, fontSize: 14)),
        ]));
      }

      // Grouper par date
      final Map<String, List<Devoir>> grouped = {};
      for (final d in state.devoirs) {
        grouped.putIfAbsent(d.pourLe, () => []).add(d);
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        children: grouped.entries.expand((entry) => [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 10),
            child: Text('Pour ${entry.key}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: Colors.white30, letterSpacing: 0.8),
            ),
          ),
          ...entry.value.map((d) => _DevoirCard(devoir: d,
              onTap: () => showModalBottomSheet(
                context: ctx, isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChangeNotifierProvider.value(
                    value: state, child: DevoirDetailSheet(devoir: d))))),
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
          color: devoir.fait ? const Color(0xFF6FCF97).withOpacity(0.05) : const Color(0xFF02040E).withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: devoir.fait ? const Color(0xFF6FCF97).withOpacity(0.15) : Colors.white.withOpacity(0.09)),
        ),
        child: Row(children: [
          // Barre couleur
          Container(width: 3, height: 38, decoration: BoxDecoration(
              color: devoir.fait ? const Color(0xFF6FCF97) : clr,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          // Checkbox
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
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(devoir.matiere, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: clr)),
            Text(devoir.type, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          // Date
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

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS SHEET
// ═══════════════════════════════════════════════════════════════════════════

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: context.read<AppState>().serverUrl);
  }

  @override
  void dispose() { _urlCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (ctx, state, _) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF060A18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Handle
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 22),
              Text('Paramètres', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 20),

              _SectionLabel('NOTIFICATIONS'),
              _SettingsTile('Nouvelles notes', '📊', state.notifNotes, state.setNotifNotes),
              _SettingsTile('Nouveaux devoirs', '📚', state.notifDevoirs, state.setNotifDevoirs),
              const SizedBox(height: 16),

              _SectionLabel('COMPORTEMENT'),
              _SettingsTile('Mode actif (30s)', '⚡', state.activeMode, state.setActiveMode),
              const SizedBox(height: 16),

              _SectionLabel('SERVEUR'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('URL du serveur', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'https://mon-serveur.com',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true, fillColor: Colors.white.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
                    ),
                    onChanged: (v) => state.setServerUrl(v.trim()),
                  ),
                  const SizedBox(height: 8),
                  Text('Le serveur surveille l\'ENT toutes les 30s et se reconnecte automatiquement.',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                ]),
              ),
              const SizedBox(height: 20),

              // Déconnexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    state.logout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB5757).withOpacity(0.15),
                    foregroundColor: const Color(0xFFEB5757),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFEB5757), width: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text('Version 1.0 · Polling 30s · ENT Auvergne-Rhône-Alpes',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.25)))),
            ]),
          ),
        ),
      );
    });
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: Colors.white30, letterSpacing: 1.0)),
  );
}

class _SettingsTile extends StatelessWidget {
  final String label, icon;
  final bool value;
  final Future<void> Function(bool) onChanged;
  const _SettingsTile(this.label, this.icon, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
      Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6FCF97)),
    ]),
  );
}
