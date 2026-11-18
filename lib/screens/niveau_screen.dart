import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecon.dart';
import '../models/niveau.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_gold.dart';
import 'lecon_screen.dart';

class NiveauScreen extends StatefulWidget {
  final Niveau niveau;

  const NiveauScreen({super.key, required this.niveau});

  @override
  State<NiveauScreen> createState() => _NiveauScreenState();
}

class _NiveauScreenState extends State<NiveauScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCat = 'all';
  String _searchQuery = '';

  final List<(String, String)> _categories = const [
    ('all', 'Tout'),
    ('gram', 'Grammaire'),
    ('conj', 'Conjugaison'),
    ('orth', 'Orthographe'),
    ('voc', 'Vocabulaire'),
    ('style', 'Style et sens'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final storage = Provider.of<StorageService>(context);

    final filteredLecons = dataService.filtrerLecons(
      widget.niveau.lecons,
      categorie: _selectedCat,
      requete: _searchQuery,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.niveau.nom),
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres de catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
            ),
            child: Column(
              children: [
                // Champ de recherche
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Chercher une leçon (ex. : participe passé, cause)...',
                    hintStyle: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 14,
                      color: AppColors.ink.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Chips de catégorie
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((c) {
                      final isSelected = _selectedCat == c.$1;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(c.$2),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCat = c.$1);
                            }
                          },
                          selectedColor: AppColors.navy,
                          backgroundColor: AppColors.card,
                          labelStyle: TextStyle(
                            fontFamily: AppTheme.fontTinos,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.navy,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.gold : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Liste des leçons
          Expanded(
            child: filteredLecons.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Aucune leçon ne correspond à votre recherche.\nEssayez un autre mot.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontTinos,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.ink.withOpacity(0.6),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: filteredLecons.length,
                    itemBuilder: (context, index) {
                      final lecon = filteredLecons[index];
                      final exIds = lecon.exercices.map((e) => e.id).toList();
                      final progress = storage.getLeconProgress(lecon.id, exIds);
                      final double pct = (progress['pct'] as double?) ?? 0.0;
                      final bool completed = (progress['completed'] as bool?) ?? false;

                      return _buildLeconTile(context, lecon, pct, completed);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeconTile(
    BuildContext context,
    Lecon lecon,
    double pct,
    bool isCompleted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeconScreen(lecon: lecon),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCompleted ? AppColors.success.withOpacity(0.6) : AppColors.border,
                width: isCompleted ? 1.4 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Indicateur de réussite ou progression
                if (isCompleted)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.15),
                      border: Border.all(color: AppColors.success, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 24,
                    ),
                  )
                else
                  CircularProgressGold(
                    percentage: pct,
                    size: 44,
                    strokeWidth: 3.5,
                  ),
                const SizedBox(width: 14),

                // Titre et badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Badge catégorie
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lecon.categorieLibelle,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Badge niveau
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              lecon.niveau,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          if (lecon.aValider) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.warning, width: 0.8),
                              ),
                              child: const Text(
                                'À valider',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lecon.titre,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTinos,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lecon.exercices.length} exercices d’application',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.ink.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: AppColors.gold,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
