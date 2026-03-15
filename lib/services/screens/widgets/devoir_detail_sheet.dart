import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../screens/main_app_screen.dart' show matiereColor;

class DevoirDetailSheet extends StatefulWidget {
  final Devoir devoir;
  const DevoirDetailSheet({super.key, required this.devoir});
  @override
  State<DevoirDetailSheet> createState() => _DevoirDetailSheetState();
}

class _DevoirDetailSheetState extends State<DevoirDetailSheet> {
  String _description = '';
  bool   _loading     = true;

  @override
  void initState() {
    super.initState();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final state = context.read<AppState>();
    if (widget.devoir.detailUrl != null) {
      final desc = await state.fetchDevoirDetail(widget.devoir.detailUrl!);
      if (mounted) setState(() { _description = desc; _loading = false; });
    } else {
      setState(() {
        _description = '${widget.devoir.matiere} · ${widget.devoir.type}\n\nTravail à rendre pour le ${widget.devoir.pourLe}.\nDonné le ${widget.devoir.donneLe}.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d   = widget.devoir;
    final clr = matiereColor(d.matiere);

    return Consumer<AppState>(builder: (ctx, state, _) {
      final done = state.devoirs.firstWhere((x) => x.id == d.id, orElse: () => d).fait;

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

              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFF2F80ED).withOpacity(0.25)),
                ),
                child: const Text('DEVOIR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: Color(0xFF56CCF2), letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),

              Text(d.matiere, style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w800, color: clr, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(d.type, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 20),

              // Grid infos
              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                children: [
                  _InfoTile('POUR LE', d.pourLe, const Color(0xFF56CCF2)),
                  _InfoTile('DONNÉ LE', d.donneLe, Colors.white),
                  _InfoTile('TYPE', d.type, Colors.white),
                  _InfoTile('STATUT', done ? '✓ Fait' : '⬜ À faire', done ? const Color(0xFF6FCF97) : Colors.white),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              const Text('DESCRIPTION DU TRAVAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: Colors.white30, letterSpacing: 1.0)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 80, maxHeight: 220),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: _loading
                  ? const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38)),
                      SizedBox(width: 10),
                      Text('Chargement…', style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ]))
                  : SingleChildScrollView(child: Text(_description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6))),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () {
                    state.toggleDevoir(d.id);
                    Navigator.pop(context);
                  },
                  icon: Icon(done ? Icons.undo_rounded : Icons.check_rounded, size: 18),
                  label: Text(done ? 'Marquer non fait' : 'Marquer comme fait'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.07),
                    foregroundColor: Colors.white60,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.white12)),
                  ),
                  child: const Text('Fermer'),
                )),
              ]),
            ]),
          ),
        ),
      );
    });
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _InfoTile(this.label, this.value, this.valueColor);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white30, letterSpacing: 0.8)),
      const SizedBox(height: 5),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor), maxLines: 2, overflow: TextOverflow.ellipsis),
    ]),
  );
}
