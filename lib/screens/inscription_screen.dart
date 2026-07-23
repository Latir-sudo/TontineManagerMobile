import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'connexion_screen.dart';
import 'main_navigation_screen.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedLocalite = 'Dakar';

  final List<String> _localites = [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Ziguinchor',
    'Kaolack',
    'Tambacounda',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                transform: Matrix4.translationValues(0, -28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'Nom complet',
                      child: TextField(
                        controller: _nomController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          hint: 'Ex: Amadou Diop',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildField(
                      label: 'Localité',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedLocalite,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.grey),
                            items: _localites.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 18, color: AppColors.grey),
                                    const SizedBox(width: 10),
                                    Text(item),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedLocalite = val!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildField(
                      label: 'Email',
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hint: 'votre@email.com',
                          icon: Icons.email_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildField(
                      label: 'Mot de passe',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                  color: AppColors.grey.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: AppColors.lightGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.grey, size: 20),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 6),
                              Text(
                                'Minimum 8 caractères',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MainNavigationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ConnexionScreen()),
                            );
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 56),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rejoignez la communauté Tontine-Manager',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5)),
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
    );
  }
}
