import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecon.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lettrine_text.dart';
import '../widgets/ornament_divider.dart';
import '../widgets/rich_text_parser.dart';
import '../widgets/schemas/schema_dispatcher.dart';
import 'exercice_screen.dart';

class LeconScreen extends StatelessWidget {
  final Lecon lecon;

  const LeconScreen({super.key, required this.lecon});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final double fontScale = storage.fontScale;

    final baseTextStyle = TextStyle(
      fontFamily: AppTheme.fontTinos,
      fontSize: 16.5 * fontScale,
      color: AppColors.ink,
      height: 1.6,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lecon.categorieLibelle),
        actions: [
          // Contrôleur de taille de police A- / A+
          IconButton(
            icon: const Text(
              'A−',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            tooltip: 'Réduire le texte',
            onPressed: () => storage.decreaseFontSize(),
          ),
          IconButton(
            icon: const Text(
              'A+',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            tooltip: 'Agrandir le texte',
            onPressed: () => storage.increaseFontSize(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Badge catégorie et niveau
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lecon.categorieLibelle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Text(
                    lecon.niveau,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Grand Titre en petites capitales espacées
            Text(
              lecon.titre.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontTinos,
                fontSize: 22 * fontScale,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.navy,
                height: 1.3,
              ),
            ),

            const OrnamentDivider(symbol: '❦', width: 160),
            const SizedBox(height: 12),

            // Blocs de contenu
            ...lecon.contenu.asMap().entries.map((entry) {
              final int index = entry.key;
              final BlocContenu bloc = entry.value;

              if (bloc is BlocParagraphe) {
                // Le tout premier paragraphe reçoit la lettrine dorée comme dans les livres anciens
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: LettrineText(
                      text: bloc.texte,
                      baseStyle: baseTextStyle,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: RichTextParser.buildRichText(
                      bloc.texte,
                      baseStyle: baseTextStyle,
                    ),
                  );
                }
              } else if (bloc is BlocExemple) {
                return _buildExempleCard(bloc.texte, fontScale);
              } else if (bloc is BlocTableau) {
                return _buildTableau(bloc, fontScale);
              } else if (bloc is BlocSchema) {
                return SchemaDispatcher(schemaId: bloc.id);
              }

              return const SizedBox.shrink();
            }),

            const SizedBox(height: 24),
            const OrnamentDivider(symbol: '✦', width: 180),
            const SizedBox(height: 16),

            // Grand bouton élégant « Faire les exercices »
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciceScreen(
                      lecon: lecon,
                      exerciceIndex: 0,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mode_edit_outline, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'FAIRE LES EXERCICES (${lecon.exercices.length})',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 16 * fontScale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExempleCard(String texte, double fontScale) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.menu_book, size: 16, color: AppColors.gold),
              SizedBox(width: 6),
              Text(
                'EXEMPLES & ILLUSTRATIONS',
                style: TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichTextParser.buildRichText(
            texte,
            baseStyle: TextStyle(
              fontFamily: AppTheme.fontTinos,
              fontSize: 15.5 * fontScale,
              fontStyle: FontStyle.italic,
              color: AppColors.navy,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableau(BlocTableau bloc, double fontScale) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.card),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.hovered)
                ? AppColors.card.withOpacity(0.5)
                : Colors.white;
          }),
          headingTextStyle: TextStyle(
            fontFamily: AppTheme.fontTinos,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
            fontSize: 14 * fontScale,
          ),
          dataTextStyle: TextStyle(
            fontFamily: AppTheme.fontTinos,
            color: AppColors.ink,
            fontSize: 13.5 * fontScale,
          ),
          border: TableBorder.all(color: AppColors.border, width: 1),
          columns: bloc.entetes.map((h) {
            return DataColumn(
              label: Text(h),
            );
          }).toList(),
          rows: bloc.lignes.map((row) {
            return DataRow(
              cells: row.map((cell) {
                return DataCell(
                  RichTextParser.buildRichText(
                    cell,
                    baseStyle: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 13.5 * fontScale,
                      color: AppColors.ink,
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
