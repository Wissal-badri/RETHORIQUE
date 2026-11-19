import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lecon.dart';
import '../models/niveau.dart';
import 'correction_engine.dart';

class DataService {
  final Map<String, Niveau> _niveauxCache = {};

  static const List<String> codesNiveaux = ['1ac', '2ac', '3ac', 'tc', '1bac'];

  Future<Niveau> getNiveau(String code) async {
    if (_niveauxCache.containsKey(code)) {
      return _niveauxCache[code]!;
    }

    String path;
    switch (code) {
      case '1ac':
        path = 'assets/data/1ac.json';
        break;
      case '2ac':
        path = 'assets/data/2ac.json';
        break;
      case '3ac':
        path = 'assets/data/3ac.json';
        break;
      case 'tc':
        path = 'assets/data/tronc_commun.json';
        break;
      case '1bac':
        path = 'assets/data/1bac.json';
        break;
      default:
        path = 'assets/data/3ac.json';
        break;
    }

    final jsonStr = await rootBundle.loadString(path);
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final niveau = Niveau.fromJson(data);
    _niveauxCache[code] = niveau;
    return niveau;
  }

  Future<List<Niveau>> getTousNiveaux() async {
    final List<Niveau> list = [];
    for (final code in codesNiveaux) {
      final n = await getNiveau(code);
      list.add(n);
    }
    return list;
  }

  /// Recherche filtrée insensible aux accents et à la casse
  List<Lecon> filtrerLecons(
    List<Lecon> lecons, {
    String categorie = 'all',
    String requete = '',
  }) {
    final queryNorm = CorrectionEngine.normaliserSansAccents(requete.trim());

    return lecons.where((l) {
      // Filtre catégorie
      if (categorie != 'all' && l.categorie != categorie) {
        return false;
      }

      // Filtre recherche
      if (queryNorm.isEmpty) {
        return true;
      }

      final titreNorm = CorrectionEngine.normaliserSansAccents(l.titre);
      final niveauNorm = CorrectionEngine.normaliserSansAccents(l.niveau);
      final catLibelleNorm = CorrectionEngine.normaliserSansAccents(l.categorieLibelle);

      if (titreNorm.contains(queryNorm) ||
          niveauNorm.contains(queryNorm) ||
          catLibelleNorm.contains(queryNorm)) {
        return true;
      }

      // Recherche dans le contenu des blocs
      for (final bloc in l.contenu) {
        if (bloc is BlocParagraphe) {
          if (CorrectionEngine.normaliserSansAccents(bloc.texte).contains(queryNorm)) {
            return true;
          }
        } else if (bloc is BlocExemple) {
          if (CorrectionEngine.normaliserSansAccents(bloc.texte).contains(queryNorm)) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }
}
