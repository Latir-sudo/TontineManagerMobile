import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tontine_service.dart';
import '../services/session_service.dart';
import '../models/cotisation.dart';

class HistoriqueCotisationScreen extends StatefulWidget {
  const HistoriqueCotisationScreen({super.key});

  @override
  State<HistoriqueCotisationScreen> createState() =>
      _HistoriqueCotisationScreenState();
}

class _HistoriqueCotisationScreenState
    extends State<HistoriqueCotisationScreen> {
  final _tontineService = TontineService();
  String _selectedFilter = 'tous';
  List<Cotisation> _cotisations = [];
  int _totalCotise = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCotisations();
  }

  Future<void> _loadCotisations() async {
    final user = SessionService.currentAppUser;
    if (user == null) return;

    final cotisations = await _tontineService.getHistoriqueCotisations(user.uid);
    final total = _tontineService.calculerTotalFromList(cotisations);

    if (mounted) {
      setState(() {
        _cotisations = cotisations;
        _totalCotise = total;
        _isLoading = false;
      });
    }
  }

  List<Cotisation> get _filteredCotisations {
    if (_selectedFilter == 'tous') return _cotisations;
    return _cotisations.where((c) => c.statut == _selectedFilter).toList();
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
  Widget build(BuildContext context) {
    final paiementsReussis = _cotisations.where((c) => c.statut == 'payee').length;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, paiementsReussis),
            const SizedBox(height: 20),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCotisations.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune cotisation',
                            style: TextStyle(color: AppColors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filteredCotisations.length,
                          itemBuilder: (context, index) {
                            return _buildCotisationCard(_filteredCotisations[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int paiementsReussis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Historique des cotisations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Total cotisations',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatMontant(_totalCotise)} FCFA',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$paiementsReussis paiements réussis',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('Tous', 'tous'),
          const SizedBox(width: 8),
          _buildFilterChip('Réussis', 'payee'),
          const SizedBox(width: 8),
          _buildFilterChip('Echoué', 'echouee'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCotisationCard(Cotisation cotisation) {
    final isSuccess = cotisation.statut == 'payee';
    final mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final dateStr = '${cotisation.date.day} ${mois[cotisation.date.month]} ${cotisation.date.year}';
    final timeStr = '${cotisation.date.hour.toString().padLeft(2, '0')}:${cotisation.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.close,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cotisation.tontineNom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cotisation.userNom,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${_formatMontant(cotisation.montant)} FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isSuccess ? 'Réussi' : 'Echoué',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${cotisation.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
