import 'package:flutter/material.dart';
import 'arbre_participe_passe_widget.dart';
import 'carte_classes_mots_widget.dart';
import 'cartes_figures_style_widget.dart';
import 'discours_direct_indirect_widget.dart';
import 'frise_temps_widget.dart';
import 'phrase_complexe_widget.dart';
import 'roue_circonstancielles_widget.dart';
import 'schema_fonctions_widget.dart';

class SchemaDispatcher extends StatelessWidget {
  final String schemaId;

  const SchemaDispatcher({super.key, required this.schemaId});

  @override
  Widget build(BuildContext context) {
    switch (schemaId) {
      case 'frise_temps':
        return const FriseTempsWidget();
      case 'arbre_participe_passe':
        return const ArbreParticipePasseWidget();
      case 'schema_phrase_complexe':
        return const PhraseComplexeWidget();
      case 'carte_classes_mots':
        return const CarteClassesMotsWidget();
      case 'schema_fonctions':
        return const SchemaFonctionsWidget();
      case 'roue_circonstancielles':
        return const RoueCirconstanciellesWidget();
      case 'discours_direct_indirect':
        return const DiscoursDirectIndirectWidget();
      case 'cartes_figures_style':
        return const CartesFiguresStyleWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}
