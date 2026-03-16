import 'package:flutter/painting.dart';

class NoteEval {
  final String id;
  final double valeur;
  final double bareme;
  final String titre;
  final String date;
  final double coefficient;

  const NoteEval({
    required this.id,
    required this.valeur,
    required this.bareme,
    required this.titre,
    required this.date,
    required this.coefficient,
  });

  factory NoteEval.fromJson(Map<String, dynamic> j) => NoteEval(
    id:           j['id']           as String,
    valeur:       (j['valeur']      as num).toDouble(),
    bareme:       (j['bareme']      as num).toDouble(),
    titre:        j['titre']        as String,
    date:         j['date']         as String,
    coefficient:  (j['coefficient'] as num).toDouble(),
  );

  String get appreciation {
    final p = valeur / bareme * 100;
    if (p >= 90) return 'Excellent ! 🏆';
    if (p >= 80) return 'Très bien ! 🎉';
    if (p >= 70) return 'Bien ! 👍';
    if (p >= 60) return 'Correct 😊';
    if (p >= 50) return 'Peut mieux faire 💪';
    if (p >= 40) return 'Insuffisant 😬';
    return 'À rattraper 💡';
  }

  String get valeurStr => valeur == valeur.roundToDouble()
      ? valeur.toInt().toString()
      : valeur.toStringAsFixed(1);

  String get baremeStr => bareme == bareme.roundToDouble()
      ? bareme.toInt().toString()
      : bareme.toStringAsFixed(1);
}

class NoteMatiere {
  final String matiere;
  final String moyenne;
  final List<NoteEval> evals;

  const NoteMatiere({
    required this.matiere,
    required this.moyenne,
    required this.evals,
  });

  factory NoteMatiere.fromJson(Map<String, dynamic> j) => NoteMatiere(
    matiere: j['matiere'] as String,
    moyenne: j['moyenne'] as String? ?? '',
    evals:   (j['evals'] as List<dynamic>)
        .map((e) => NoteEval.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  double? get moyenneNum => double.tryParse(moyenne.replaceAll(',', '.'));

  Color get moyenneColor {
    final n = moyenneNum;
    if (n == null) return const Color(0xFFFFFFFF);
    if (n >= 14)   return const Color(0xFF6FCF97);
    if (n >= 10)   return const Color(0xFFF2994A);
    return const Color(0xFFEB5757);
  }
}

class Devoir {
  final String id;
  final String matiere;
  final String pourLe;
  final String donneLe;
  final String type;
  final String? detailUrl;
  bool fait;

  Devoir({
    required this.id,
    required this.matiere,
    required this.pourLe,
    required this.donneLe,
    required this.type,
    this.detailUrl,
    required this.fait,
  });

  factory Devoir.fromJson(Map<String, dynamic> j) => Devoir(
    id:        j['id']         as String,
    matiere:   j['matiere']    as String,
    pourLe:    j['pour_le']    as String,
    donneLe:   j['donne_le']   as String,
    type:      j['type']       as String,
    detailUrl: j['detail_url'] as String?,
    fait:      j['fait']       as bool? ?? false,
  );
}

class ServerNotif {
  final String type;
  final String title;
  final String body;

  const ServerNotif({required this.type, required this.title, required this.body});

  factory ServerNotif.fromJson(Map<String, dynamic> j) => ServerNotif(
    type:  j['type']  as String,
    title: j['title'] as String,
    body:  j['body']  as String,
  );
}
