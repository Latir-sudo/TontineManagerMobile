import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/tontine.dart';
import '../models/cotisation.dart';
import '../services/tontine_service.dart';

class CotisationsTourScreen extends StatefulWidget {
  final String tontineId;

  const CotisationsTourScreen({super.key, required this.tontineId});

  @override
  State<CotisationsTourScreen> createState() => _CotisationsTourScreenState();
}

class _CotisationsTourScreenState extends State<CotisationsTourScreen> {
  final _tontineService = TontineService();
  Tontine? _tontine;
  List<Cotisation> _cotisations = [];
  List<_Tour> _tours = [];
  bool _isLoading = true;
  int _selectedTourIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tontine = await _tontineService.getTontine(widget.tontineId);
      if (tontine == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final cotisations =
          await _tontineService.getCotisationsTontine(widget.tontineId);

      final membres = await _tontineService.getMembresTontine(tontine.membresUids);
      for (final m in membres) {
        _nomsCache[m.uid] = m.nom;
      }

      final tours = _calculerTours(tontine, cotisations);

      if (mounted) {
        setState(() {
          _tontine = tontine;
          _cotisations = cotisations;
          _tours = tours;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_Tour> _calculerTours(Tontine tontine, List<Cotisation> cotisations) {
    final now = DateTime.now();
    final debut = tontine.dateDebut;
    final frequence = tontine.frequence.toLowerCase();

    int dureeJours;
    switch (frequence) {
      case 'hebdomadaire':
        dureeJours = 7;
        break;
      case 'bimensuel':
        dureeJours = 15;
        break;
      case 'mensuel':
      default:
        dureeJours = 30;
        break;
    }

    final tours = <_Tour>[];
    var tourDebut = debut;
    int tourNum = 1;

    while (tourDebut.isBefore(now)) {
      final tourFin = tourDebut.add(Duration(days: dureeJours));

      final cotisationsDuTour = cotisations.where((c) {
        return !c.date.isBefore(tourDebut) && c.date.isBefore(tourFin);
      }).toList();

      final membresPayes =
          cotisationsDuTour.map((c) => c.userUid).toSet().toList();

      final membresNonPayes = tontine.membresUids
          .where((uid) => !membresPayes.contains(uid))
          .toList();

      tours.add(_Tour(
        numero: tourNum,
        dateDebut: tourDebut,
        dateFin: tourFin,
        cotisations: cotisationsDuTour,
        membresPayesUids: membresPayes,
        membresNonPayesUids: membresNonPayes,
        isEnCours: now.isAfter(tourDebut) && now.isBefore(tourFin),
      ));

      tourDebut = tourFin;
      tourNum++;
    }

    if (tours.isEmpty) {
      final tourFin = debut.add(Duration(days: dureeJours));
      tours.add(_Tour(
        numero: 1,
        dateDebut: debut,
        dateFin: tourFin,
        cotisations: [],
        membresPayesUids: [],
        membresNonPayesUids: tontine.membresUids,
        isEnCours: true,
      ));
    }

    return tours.reversed.toList();
  }

  String _formatDate(DateTime date) {
    final mois = [
      '',
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return '${date.day} ${mois[date.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tontine == null
                ? const Center(child: Text('Tontine introuvable'))
                : Column(
                    children: [
                      _buildHeader(),
                      _buildTourSelector(),
                      Expanded(child: _buildTourContent()),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    final tontine = _tontine!;
    final totalPayes = _cotisations.length;
    final totalAttendu =
        _tours.fold<int>(0, (sum, t) => sum + tontine.membresUids.length);
    final progression =
        totalAttendu > 0 ? (totalPayes / totalAttendu).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suivi des cotisations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tontine.nom,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_tours.length} tour${_tours.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fréquence: ${tontine.frequence}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progression,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor:
                            AppColors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50)),
                      ),
                      Text(
                        '${(progression * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTourSelector() {
    if (_tours.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tours.length,
        itemBuilder: (context, index) {
          final tour = _tours[index];
          final isSelected = _selectedTourIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedTourIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? null
                    : Border.all(
                        color: AppColors.grey.withValues(alpha: 0.2)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tour ${tour.numero}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.white : AppColors.darkText,
                    ),
                  ),
                  if (tour.isEnCours)
                    Text(
                      'En cours',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.white.withValues(alpha: 0.7)
                            : const Color(0xFF4CAF50),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourContent() {
    if (_tours.isEmpty) {
      return const Center(
        child: Text(
          'Aucun tour disponible',
          style: TextStyle(fontSize: 15, color: AppColors.grey),
        ),
      );
    }

    final tour = _tours[_selectedTourIndex];
    final tontine = _tontine!;
    final payesCount = tour.membresPayesUids.length;
    final totalMembres = tontine.membresUids.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTourInfoCard(tour, payesCount, totalMembres),
          const SizedBox(height: 20),
          if (tour.membresPayesUids.isNotEmpty) ...[
            _buildSectionTitle(
              'Ont cotisé',
              Icons.check_circle,
              const Color(0xFF4CAF50),
              payesCount,
            ),
            const SizedBox(height: 10),
            ...tour.cotisations.map((c) => _buildMembrePayeCard(c)),
          ],
          if (tour.membresNonPayesUids.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionTitle(
              'En attente',
              Icons.hourglass_empty,
              const Color(0xFFFF9800),
              tour.membresNonPayesUids.length,
            ),
            const SizedBox(height: 10),
            ...tour.membresNonPayesUids
                .map((uid) => _buildMembreNonPayeCard(uid)),
          ],
        ],
      ),
    );
  }

  Widget _buildTourInfoCard(
      _Tour tour, int payesCount, int totalMembres) {
    final progression =
        totalMembres > 0 ? payesCount / totalMembres : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tour ${tour.numero}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(tour.dateDebut)} - ${_formatDate(tour.dateFin)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tour.isEnCours
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                      : AppColors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tour.isEnCours ? 'En cours' : 'Terminé',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tour.isEnCours
                        ? const Color(0xFF4CAF50)
                        : AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progression,
                    minHeight: 8,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progression >= 1.0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$payesCount/$totalMembres',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, Color color, int count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembrePayeCard(Cotisation cotisation) {
    final initials = cotisation.userNom.isNotEmpty
        ? cotisation.userNom
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cotisation.userNom,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(cotisation.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: Color(0xFF4CAF50)),
                SizedBox(width: 4),
                Text(
                  'Payé',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembreNonPayeCard(String uid) {
    final displayNom = _nomsCache[uid] ?? uid.substring(0, 6);
    final displayInitials = displayNom.isNotEmpty
        ? displayNom
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayInitials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF9800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayNom,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty,
                    size: 14, color: Color(0xFFFF9800)),
                SizedBox(width: 4),
                Text(
                  'En attente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final Map<String, String> _nomsCache = {};
}

class _Tour {
  final int numero;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<Cotisation> cotisations;
  final List<String> membresPayesUids;
  final List<String> membresNonPayesUids;
  final bool isEnCours;

  _Tour({
    required this.numero,
    required this.dateDebut,
    required this.dateFin,
    required this.cotisations,
    required this.membresPayesUids,
    required this.membresNonPayesUids,
    required this.isEnCours,
  });
}
