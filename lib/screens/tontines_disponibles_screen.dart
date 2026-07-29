import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/tontine_service.dart';
import '../services/session_service.dart';
import '../models/tontine.dart';
import 'detail_tontine_screen.dart';

class TontinesDisponiblesScreen extends StatefulWidget {
  const TontinesDisponiblesScreen({super.key});

  @override
  State<TontinesDisponiblesScreen> createState() =>
      _TontinesDisponiblesScreenState();
}

class _TontinesDisponiblesScreenState extends State<TontinesDisponiblesScreen> {
  final _tontineService = TontineService();
  final _searchController = TextEditingController();
  String _selectedFilter = 'Toutes';
  List<Tontine> _tontines = [];
  bool _isLoading = true;

  final List<String> _filters = [
    'Toutes',
    'Dakar',
    'Thiès',
    'Saint-Louis',
  ];

  @override
  void initState() {
    super.initState();
    _loadTontines();
  }

  Future<void> _loadTontines() async {
    final user = SessionService.currentAppUser;
    if (user == null) return;

    final tontines = await _tontineService.getTontinesDisponibles(user.uid);
    if (mounted) {
      setState(() {
        _tontines = tontines;
        _isLoading = false;
      });
    }
  }

  List<Tontine> get _filteredTontines {
    var filtered = _tontines.toList();

    if (_selectedFilter != 'Toutes') {
      filtered = filtered.where((t) => t.localite == _selectedFilter).toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.nom.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query) ||
              t.localite.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  String _formatMontant(int montant) {
    if (montant == 0) return '0';
    final str = montant.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTontines.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: _filteredTontines.length,
                          itemBuilder: (context, index) =>
                              _buildTontineCard(_filteredTontines[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.explore,
                    color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tontines Disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Rechercher une tontine...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey.withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.grey, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.grey.withValues(alpha: 0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppColors.primaryDark.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? AppColors.white : AppColors.darkText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64,
              color: AppColors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Aucune tontine trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre filtre ou mot-clé',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.grey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTontineCard(Tontine tontine) {
    final int membres = tontine.membresUids.length;
    final int maxMembres = tontine.maxMembres;
    final bool isFull = membres >= maxMembres;
    final double progress = membres / maxMembres;
    final dateFormat = DateFormat('dd MMM yyyy');

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = const Color(0xFFE53935);
    } else if (progress >= 0.75) {
      progressColor = AppColors.accent;
    } else {
      progressColor = AppColors.accent;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetailTontineScreen(tontineId: tontine.id)),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tontine.nom,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tontine.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatMontant(tontine.montantCotisation)} FCFA',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tontine.frequence,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.grey.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text(
                  tontine.localite,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_outline,
                    size: 18,
                    color: AppColors.grey.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Text(
                  '$membres/$maxMembres membres',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: AppColors.lightGrey,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.grey.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Text(
                  'Début ${dateFormat.format(tontine.dateDebut)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey.withValues(alpha: 0.9),
                  ),
                ),
                if (isFull) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Complet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFull
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailTontineScreen(tontineId: tontine.id)),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFull ? AppColors.grey.withValues(alpha: 0.3) : AppColors.accent,
                  disabledBackgroundColor:
                      AppColors.grey.withValues(alpha: 0.15),
                  disabledForegroundColor: AppColors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: isFull ? 0 : 2,
                  shadowColor: AppColors.accent.withValues(alpha: 0.3),
                ),
                child: Text(
                  isFull ? 'Tontine complète' : 'Voir les détails',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
