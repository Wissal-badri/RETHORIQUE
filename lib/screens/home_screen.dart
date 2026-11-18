import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/niveau.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_gold.dart';
import '../widgets/ornament_divider.dart';
import 'a_propos_screen.dart';
import 'niveau_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _revealAnim;
  late Animation<double> _fadeSubtitleAnim;

  List<Niveau> _niveaux = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Animation de tracé à la plume de « Rhétorique » (1.5 secondes)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _revealAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeInOutCubic),
    );

    _fadeSubtitleAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
    );

    _animController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = Provider.of<DataService>(context, listen: false);
    final n3ac = await dataService.getNiveau('3ac');
    final n1bac = await dataService.getNiveau('1bac');
    final ntc = await dataService.getNiveau('tc');

    if (mounted) {
      setState(() {
        _niveaux = [n3ac, n1bac, ntc];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rhétorique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.goldLight),
            tooltip: 'À propos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AProposScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : RefreshIndicator(
              color: AppColors.gold,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête calligraphique avec révélation à la plume
                    Center(
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _revealAnim,
                            builder: (context, child) {
                              return ClipRect(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _revealAnim.value,
                                  child: const Text(
                                    'Rhétorique',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontPinyon,
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          FadeTransition(
                            opacity: _fadeSubtitleAnim,
                            child: Column(
                              children: const [
                                SizedBox(height: 4),
                                Text(
                                  '« L’art de Molière »',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontTinos,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.gold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Par BADRI Chakib, professeur de français',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontTinos,
                                    fontSize: 13,
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const OrnamentDivider(symbol: '❦', width: 220),
                    const SizedBox(height: 8),

                    const Text(
                      'CHOISISSEZ VOTRE NIVEAU D’ÉTUDE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontTinos,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cartes des niveaux
                    ..._niveaux.map((niveau) {
                      final allExIds = niveau.lecons
                          .expand((l) => l.exercices.map((e) => e.id))
                          .toList();

                      final progress = storage.getLeconProgress(niveau.code, allExIds);
                      final double pct = (progress['pct'] as double?) ?? 0.0;

                      return _buildNiveauCard(context, niveau, pct);
                    }),

                    const SizedBox(height: 16),
                    // Citation de Molière
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            '« La parole a été donnée à l’homme pour exprimer ses pensées. »',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontTinos,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '— Molière',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNiveauCard(BuildContext context, Niveau niveau, double progressionPct) {
    final bool estDisponible = niveau.lecons.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: estDisponible
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NiveauScreen(niveau: niveau),
                    ),
                  );
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le niveau Tronc Commun sera bientôt disponible via enrichissement JSON.'),
                      backgroundColor: AppColors.navy,
                    ),
                  );
                },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircularProgressGold(
                  percentage: progressionPct,
                  size: 56,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        niveau.nom,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTinos,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estDisponible
                            ? '${niveau.lecons.length} leçons complètes'
                            : 'Bientôt disponible',
                        style: TextStyle(
                          fontSize: 13,
                          color: estDisponible ? AppColors.gold : AppColors.ink.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        niveau.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.ink.withOpacity(0.75),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
