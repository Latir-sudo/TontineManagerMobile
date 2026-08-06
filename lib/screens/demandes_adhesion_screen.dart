import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tontine_service.dart';
import '../models/demande_adhesion.dart';

class DemandesAdhesionScreen extends StatefulWidget {
  final String tontineId;
  const DemandesAdhesionScreen({super.key, required this.tontineId});

  @override
  State<DemandesAdhesionScreen> createState() => _DemandesAdhesionScreenState();
}

class _DemandesAdhesionScreenState extends State<DemandesAdhesionScreen> {
  final _tontineService = TontineService();
  List<DemandeAdhesion> _demandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    final demandes = await _tontineService.getDemandesPourTontine(widget.tontineId);
    if (mounted) {
      setState(() {
        _demandes = demandes;
        _isLoading = false;
      });
    }
  }

  Future<void> _accepter(DemandeAdhesion demande) async {
    final success = await _tontineService.accepterDemande(demande.id, widget.tontineId, demande.userUid);
    setState(() => _demandes.remove(demande));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Membre accepté'
            : 'Ce membre fait déjà partie de la tontine'),
        backgroundColor: success
            ? const Color(0xFF27AE60)
            : const Color(0xFFF57C00),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refuser(DemandeAdhesion demande) async {
    await _tontineService.refuserDemande(demande.id);
    setState(() => _demandes.remove(demande));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demande refusée'),
        backgroundColor: AppColors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Demandes d\'adhésion',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _demandes.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                size: 40, color: AppColors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune demande en attente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les nouvelles demandes apparaîtront ici',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _demandes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final demande = _demandes[index];
        return _buildDemandeCard(demande);
      },
    );
  }

  Widget _buildDemandeCard(DemandeAdhesion demande) {
    final mois = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final dateStr = '${demande.date.day} ${mois[demande.date.month]} ${demande.date.year}';

    return Container(
      padding: const EdgeInsets.all(18),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    demande.userNom.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demande.userNom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(
                          demande.userTelephone,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(
                demande.userLocalite,
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _refuser(demande),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Refuser',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _accepter(demande),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Accepter',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
