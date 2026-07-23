import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'detail_tontine_screen.dart';

class MesTontinesScreen extends StatelessWidget {
  const MesTontinesScreen({super.key});

  final List<Map<String, dynamic>> _tontines = const [
    {
      'name': 'Tontine Famille',
      'categorie': 'Epargne',
      'montant': '5 000 FCFA',
      'membres': 15,
      'maxMembres': 20,
      'frequence': 'Mensuelle',
      'prochainPaiement': '3 jours',
      'isActive': true,
    },
    {
      'name': 'Epargne Quartier',
      'categorie': 'Solidarité',
      'montant': '10 000 FCFA',
      'membres': 20,
      'maxMembres': 20,
      'frequence': 'Mensuelle',
      'prochainPaiement': '1 jour',
      'isActive': true,
    },
    {
      'name': 'Tontine Collègues',
      'categorie': 'Investissement',
      'montant': '25 000 FCFA',
      'membres': 8,
      'maxMembres': 10,
      'frequence': 'Bimensuelle',
      'prochainPaiement': '12 jours',
      'isActive': true,
    },
    {
      'name': 'Epargne Femmes',
      'categorie': 'Famille',
      'montant': '3 000 FCFA',
      'membres': 12,
      'maxMembres': 15,
      'frequence': 'Hebdomadaire',
      'prochainPaiement': 'Terminée',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeTontines = _tontines.where((t) => t['isActive'] == true).toList();
    final inactiveTontines = _tontines.where((t) => t['isActive'] == false).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(activeTontines.length, _tontines.length),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Actives',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${activeTontines.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...activeTontines.map(
                        (t) => _buildTontineCard(context, t)),
                    if (inactiveTontines.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text(
                            'Terminées',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${inactiveTontines.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...inactiveTontines.map(
                          (t) => _buildTontineCard(context, t)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int actives, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003366),
            Color(0xFF004D99),
            Color(0xFF00264D),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes tontines',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gérez et suivez vos contributions',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeaderStat(
                    icon: Icons.play_circle_outline,
                    value: '$actives',
                    label: 'Actives',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildHeaderStat(
                    icon: Icons.pie_chart_outline,
                    value: '$total',
                    label: 'Total',
                    color: AppColors.accent,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildHeaderStat(
                    icon: Icons.check_circle_outline,
                    value: '${total - actives}',
                    label: 'Terminées',
                    color: const Color(0xFF90CAF9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTontineCard(BuildContext context, Map<String, dynamic> tontine) {
    final bool isActive = tontine['isActive'];
    final int membres = tontine['membres'];
    final int maxMembres = tontine['maxMembres'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailTontineScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryDark.withValues(alpha: 0.1)
                        : AppColors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: isActive ? AppColors.primaryDark : AppColors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tontine['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tontine['categorie'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color: isActive ? Colors.green : AppColors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isActive ? 'Active' : 'Terminée',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.green : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildCardInfo(Icons.people_outline, '$membres/$maxMembres membres'),
                const SizedBox(width: 16),
                _buildCardInfo(Icons.loop, tontine['frequence']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tontine['montant'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isActive ? AppColors.accent : AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Dans ${tontine['prochainPaiement']}' : tontine['prochainPaiement'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? AppColors.accent : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.grey),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
