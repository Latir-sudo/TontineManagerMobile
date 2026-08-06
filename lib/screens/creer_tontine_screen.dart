import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tontine_service.dart';
import '../services/session_service.dart';

class CreerTontineScreen extends StatefulWidget {
  const CreerTontineScreen({super.key});

  @override
  State<CreerTontineScreen> createState() => _CreerTontineScreenState();
}

class _CreerTontineScreenState extends State<CreerTontineScreen> {
  final _tontineService = TontineService();
  final _nomController = TextEditingController();
  final _montantController = TextEditingController(text: '5000');
  final _maxMembresController = TextEditingController(text: '20');
  final _telephoneVersementController = TextEditingController();
  String? _selectedCategorie;
  String _selectedLocalite = 'Dakar';
  String? _selectedFrequence;
  bool _isLoading = false;

  final List<String> _categories = [
    'Epargne',
    'Solidarité',
    'Investissement',
    'Famille',
  ];

  final List<String> _localites = [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Ziguinchor',
    'Kaolack',
  ];

  final List<String> _frequences = [
    'Hebdomadaire',
    'Mensuel',
    'Bimensuel',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _montantController.dispose();
    _maxMembresController.dispose();
    _telephoneVersementController.dispose();
    super.dispose();
  }

  Future<void> _creerTontine() async {
    if (_nomController.text.trim().isEmpty ||
        _selectedFrequence == null ||
        _telephoneVersementController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    final user = SessionService.currentAppUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expirée. Reconnectez-vous.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _tontineService.creerTontine(
        nom: _nomController.text.trim(),
        description: _selectedCategorie ?? '',
        montantCotisation: int.tryParse(_montantController.text) ?? 5000,
        frequence: _selectedFrequence!,
        localite: _selectedLocalite,
        adminUid: user.uid,
        adminNom: user.nom,
        maxMembres: int.tryParse(_maxMembresController.text) ?? 20,
        dateDebut: DateTime.now(),
        telephoneVersement: _telephoneVersementController.text.trim(),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion. Vérifiez votre réseau et réessayez.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nom de la tontine'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        hintText: 'Ex. Epargne solidaire',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Catégorie'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: 'Sélectionnez une catégorie',
                      value: _selectedCategorie,
                      items: _categories,
                      onChanged: (val) =>
                          setState(() => _selectedCategorie = val),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: AppColors.darkText),
                        const SizedBox(width: 4),
                        _buildLabel('Localité'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: 'Sélectionnez une localité',
                      value: _selectedLocalite,
                      items: _localites,
                      onChanged: (val) =>
                          setState(() => _selectedLocalite = val!),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Montant'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _montantController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'FCFA',
                                  suffixStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Frequence'),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                hint: 'Choisir',
                                value: _selectedFrequence,
                                items: _frequences,
                                onChanged: (val) =>
                                    setState(() => _selectedFrequence = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.groups_outlined,
                            size: 18, color: AppColors.darkText),
                        const SizedBox(width: 4),
                        _buildLabel('Max membres'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _maxMembresController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 18, color: AppColors.darkText),
                        const SizedBox(width: 4),
                        _buildLabel('Téléphone de versement'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _telephoneVersementController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Ex. 77 123 45 67',
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _creerTontine,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Creer tontine'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
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
              const SizedBox(width: 8),
              const Text(
                '💰',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                'Créer une tontine',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Remplissez les informations pour créer votre tontine',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      '$text *',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: AppColors.grey, fontSize: 16),
          ),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
