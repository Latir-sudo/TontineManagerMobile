import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoriqueCotisationScreen extends StatefulWidget {
  const HistoriqueCotisationScreen({super.key});

  @override
  State<HistoriqueCotisationScreen> createState() =>
      _HistoriqueCotisationScreenState();
}

class _HistoriqueCotisationScreenState
    extends State<HistoriqueCotisationScreen> {
  String _selectedFilter = 'tous';

  final List<Map<String, dynamic>> _cotisations = [
    {
      'tontine': 'Tontine Famille',
      'method': 'Wave',
      'amount': '-5000 FCFA',
      'date': '1 er Mai 2026',
      'time': '18:00',
      'reference': '#TX004F3T3',
      'status': 'reussi',
    },
    {
      'tontine': 'Tontine Famille',
      'method': 'Wave',
      'amount': '-10 000 FCFA',
      'date': '20 janvier 2026',
      'time': '20:00',
      'reference': '#AZX004F3T3',
      'status': 'reussi',
    },
    {
      'tontine': 'Tontine Famille',
      'method': 'Wave',
      'amount': '-5000 FCFA',
      'date': '1 er Mai 2026',
      'time': '18:00',
      'reference': '#TX004F3T3',
      'status': 'echoue',
    },
  ];

  List<Map<String, dynamic>> get _filteredCotisations {
    if (_selectedFilter == 'tous') return _cotisations;
    return _cotisations
        .where((c) => c['status'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
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

  Widget _buildHeader(BuildContext context) {
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
              const Text('💰', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
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
          const Text(
            '20 000 FCFA',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '3 paiements réussis',
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
          _buildFilterChip('Réussis', 'reussi'),
          const SizedBox(width: 8),
          _buildFilterChip('Echoué', 'echoue'),
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

  Widget _buildCotisationCard(Map<String, dynamic> cotisation) {
    final isSuccess = cotisation['status'] == 'reussi';
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
                      cotisation['tontine'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cotisation['method'],
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
                    cotisation['amount'],
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
                    Icon(Icons.calendar_today, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        cotisation['date'],
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      cotisation['time'],
                      style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cotisation['reference'],
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
