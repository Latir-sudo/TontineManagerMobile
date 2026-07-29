import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tontine_service.dart';
import '../models/app_user.dart';

class AjouterMembreScreen extends StatefulWidget {
  final String tontineId;
  const AjouterMembreScreen({super.key, required this.tontineId});

  @override
  State<AjouterMembreScreen> createState() => _AjouterMembreScreenState();
}

class _AjouterMembreScreenState extends State<AjouterMembreScreen> {
  final _tontineService = TontineService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<AppUser> _utilisateurs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUtilisateurs();
  }

  Future<void> _loadUtilisateurs() async {
    final users = await _tontineService.rechercherUtilisateurs('');
    if (mounted) {
      setState(() {
        _utilisateurs = users;
        _isLoading = false;
      });
    }
  }

  List<AppUser> get _filteredUtilisateurs {
    if (_searchQuery.isEmpty) return _utilisateurs;
    final query = _searchQuery.toLowerCase().replaceAll(' ', '');
    return _utilisateurs.where((u) {
      final nom = u.nom.toLowerCase();
      final tel = u.telephone.replaceAll(' ', '');
      return nom.contains(query) || tel.contains(query);
    }).toList();
  }

  void _ajouterMembre(AppUser utilisateur) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add,
                    color: Color(0xFF27AE60), size: 28),
              ),
              const SizedBox(height: 18),
              const Text(
                'Confirmer l\'ajout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ajouter ${utilisateur.nom} à la tontine ?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey,
                        side: BorderSide(
                            color: AppColors.grey.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _tontineService.ajouterMembre(
                            widget.tontineId, utilisateur.uid);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${utilisateur.nom} ajouté à la tontine'),
                            backgroundColor: const Color(0xFF27AE60),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredUtilisateurs;

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
          'Ajouter un membre',
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom ou téléphone',
                      hintStyle:
                          const TextStyle(color: AppColors.grey, fontSize: 15),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.grey, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${results.length} utilisateur${results.length > 1 ? 's' : ''} trouvé${results.length > 1 ? 's' : ''}',
                        style:
                            const TextStyle(fontSize: 13, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          itemCount: results.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildUserCard(results[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search_outlined,
                size: 36, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vérifiez le numéro ou le nom saisi',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser utilisateur) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                utilisateur.nom.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  fontSize: 15,
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
                  utilisateur.nom,
                  style: const TextStyle(
                    fontSize: 15,
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
                      utilisateur.telephone,
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      utilisateur.localite,
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _ajouterMembre(utilisateur),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add,
                  size: 18, color: Color(0xFF27AE60)),
            ),
          ),
        ],
      ),
    );
  }
}
