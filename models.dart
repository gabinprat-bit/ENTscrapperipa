import 'package:flutter/painting.dart';

// ── NoteEval ─────────────────────────────────────────────────────────────────

class NoteEval {
  final String id, titre, date;
  final double valeur, bareme, coefficient;

  const NoteEval({
    required this.id, required this.titre, required this.date,
    required this.valeur, required this.bareme, required this.coefficient,
  });

  factory NoteEval.fromJson(Map<String, dynamic> j) => NoteEval(
    id:          j['id']          as String,
    titre:       j['titre']       as String,
    date:        j['date']        as String,
    valeur:      (j['valeur']     as num).toDouble(),
    bareme:      (j['bareme']     as num).toDouble(),
    coefficient: (j['coefficient'] as num).toDouble(),
  );

  double get pct => bareme > 0 ? valeur / bareme * 100 : 0;

  String get valeurStr => valeur == valeur.roundToDouble()
      ? valeur.toInt().toString() : valeur.toStringAsFixed(1);
  String get baremeStr => bareme == bareme.roundToDouble()
      ? bareme.toInt().toString() : bareme.toStringAsFixed(1);

  // ── Appréciation précise par tranche ──────────────────────────────────────
  AppreciationResult get appreciation {
    final p = pct;
    if (p >= 99) return AppreciationResult('Score parfait ! 🌟',         const Color(0xFF6FCF97), 'Absolument irréprochable !');
    if (p >= 95) return AppreciationResult('Exceptionnel ! 🏆',          const Color(0xFF6FCF97), 'Une maîtrise complète du sujet.');
    if (p >= 90) return AppreciationResult('Excellent ! 🎯',              const Color(0xFF6FCF97), 'Très solide, continue comme ça !');
    if (p >= 85) return AppreciationResult('Très bien ! 🎉',              const Color(0xFF6FCF97), 'Un très beau travail !');
    if (p >= 80) return AppreciationResult('Bien ! 👍',                   const Color(0xFF6FCF97), 'Belle maîtrise du cours.');
    if (p >= 75) return AppreciationResult('Bien 😊',                     const Color(0xFF6FCF97), 'Bon travail, quelques points à consolider.');
    if (p >= 70) return AppreciationResult('Assez bien 📚',               const Color(0xFFF2994A), "L'essentiel est acquis, revois les détails.");
    if (p >= 65) return AppreciationResult('Assez bien 🙂',               const Color(0xFFF2994A), 'Bonne base, peut encore progresser.');
    if (p >= 60) return AppreciationResult('Correct ✔️',                  const Color(0xFFF2994A), 'Le minimum est là, vise plus haut !');
    if (p >= 55) return AppreciationResult('Moyen 😐',                    const Color(0xFFF2994A), 'Relis le cours et refais les exercices.');
    if (p >= 50) return AppreciationResult('Peut mieux faire 💪',         const Color(0xFFF2994A), 'Accroche-toi, tu peux y arriver !');
    if (p >= 45) return AppreciationResult('Insuffisant 😬',              const Color(0xFFEB5757), "Demande de l'aide à ton prof !");
    if (p >= 40) return AppreciationResult('Insuffisant ⚠️',              const Color(0xFFEB5757), 'Ce chapitre nécessite un effort supplémentaire.');
    if (p >= 30) return AppreciationResult('À rattraper 😟',              const Color(0xFFEB5757), 'Revois tout le chapitre avec ton prof.');
    return             AppreciationResult('À rattraper 💡',               const Color(0xFFEB5757), "N'hésite pas à demander de l'aide !");
  }
}

class AppreciationResult {
  final String label, tip;
  final Color color;
  const AppreciationResult(this.label, this.color, this.tip);
}

// ── NoteMatiere ───────────────────────────────────────────────────────────────

class NoteMatiere {
  final String matiere, moyenne;
  final List<NoteEval> evals;

  const NoteMatiere({required this.matiere, required this.moyenne, required this.evals});

  factory NoteMatiere.fromJson(Map<String, dynamic> j) => NoteMatiere(
    matiere: j['matiere'] as String,
    moyenne: j['moyenne'] as String? ?? '',
    evals:   (j['evals'] as List).map((e) => NoteEval.fromJson(e as Map<String, dynamic>)).toList(),
  );

  double? get moyenneNum {
    final n = double.tryParse(moyenne.replaceAll(',', '.'));
    return (n != null && n > 0) ? n : null;
  }

  Color get moyenneColor {
    final n = moyenneNum;
    if (n == null) return const Color(0xFFFFFFFF);
    if (n >= 14) return const Color(0xFF6FCF97);
    if (n >= 10) return const Color(0xFFF2994A);
    return const Color(0xFFEB5757);
  }
}

// ── Devoir ────────────────────────────────────────────────────────────────────

class Devoir {
  final String id, matiere, pourLe, donneLe, type;
  final String? detailUrl;
  bool fait;

  Devoir({
    required this.id, required this.matiere, required this.pourLe,
    required this.donneLe, required this.type, this.detailUrl, required this.fait,
  });

  factory Devoir.fromJson(Map<String, dynamic> j) => Devoir(
    id:        j['id']        as String,
    matiere:   j['matiere']   as String,
    pourLe:    j['pour_le']   as String,
    donneLe:   j['donne_le']  as String,
    type:      j['type']      as String,
    detailUrl: j['detail_url'] as String?,
    fait:      j['fait']      as bool? ?? false,
  );
}

// ── DevoirSections ────────────────────────────────────────────────────────────

class DevoirSections {
  final List<String> travailSeance;   // avant le cours
  final List<String> activiteSeance;  // en cours
  final List<String> travailSuite;    // à faire (les vrais devoirs)

  const DevoirSections({
    required this.travailSeance,
    required this.activiteSeance,
    required this.travailSuite,
  });

  factory DevoirSections.fromJson(Map<String, dynamic> j) {
    List<String> toList(dynamic v) =>
        (v as List? ?? []).map((e) => e.toString()).toList();
    return DevoirSections(
      travailSeance:  toList(j['travail_seance']),
      activiteSeance: toList(j['activite_seance']),
      travailSuite:   toList(j['travail_suite']),
    );
  }

  bool get isEmpty =>
      travailSeance.isEmpty && activiteSeance.isEmpty && travailSuite.isEmpty;
}

// ── ServerNotif ───────────────────────────────────────────────────────────────

class ServerNotif {
  final String type, title, body;
  const ServerNotif({required this.type, required this.title, required this.body});
  factory ServerNotif.fromJson(Map<String, dynamic> j) => ServerNotif(
    type:  j['type']  as String,
    title: j['title'] as String,
    body:  j['body']  as String,
  );
}
