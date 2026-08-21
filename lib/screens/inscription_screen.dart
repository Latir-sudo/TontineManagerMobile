import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/phone_verification_service.dart';
import 'connexion_full_screen.dart';
import 'main_navigation_screen.dart';
import 'phone_verification_screen.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _authService = AuthService();
  final _phoneVerificationService = PhoneVerificationService();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  bool _pinMismatch = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedLocalite;
  String _completePhoneNumber = '';
  bool _isPhoneValid = false;

  final List<String> _localites = [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Ziguinchor',
    'Kaolack',
    'Tambacounda',
    'Rufisque',
    'Touba',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validation des champs
    if (_nomController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer votre nom complet');
      return;
    }

    if (!_isPhoneValid || _completePhoneNumber.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer un numéro de téléphone valide');
      return;
    }

    if (_selectedLocalite == null || _selectedLocalite!.isEmpty) {
      setState(() => _errorMessage = 'Veuillez sélectionner votre localité');
      return;
    }

    if (_pinController.text.length != 4) {
      setState(() => _errorMessage = 'Le code PIN doit contenir 4 chiffres');
      return;
    }

    if (_pinController.text != _pinConfirmController.text) {
      setState(() {
        _pinMismatch = true;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Étape 1 : Vérifier que le numéro n'existe pas déjà
    final existingUser = await _authService.findUserByPhone(_completePhoneNumber);
    if (existingUser != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ce numéro de téléphone est déjà utilisé';
      });
      return;
    }

    // Étape 2 : Envoyer le code de vérification
    await _phoneVerificationService.verifyPhoneNumber(
      phoneNumber: _completePhoneNumber,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        // Naviguer vers l'écran de vérification OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneVerificationScreen(
              phoneNumber: _completePhoneNumber,
              onVerificationComplete: (verified) {
                if (verified) {
                  _completeInscription();
                } else {
                  Navigator.pop(context);
                  setState(() => _errorMessage = 'Vérification échouée');
                }
              },
            ),
          ),
        );
      },
      onVerificationCompleted: () {
        // Vérification automatique réussie (Android uniquement)
        if (!mounted) return;
        setState(() => _isLoading = false);
        _completeInscription();
      },
      onVerificationFailed: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      },
    );
  }

  /// Complète l'inscription après vérification du téléphone
  Future<void> _completeInscription() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.inscription(
      nom: _nomController.text.trim(),
      telephone: _completePhoneNumber,
      localite: _selectedLocalite ?? '',
      pin: _pinController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      SessionService().setCurrentUser(result.user!);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      setState(() => _errorMessage = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildFormFields(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 18, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 20),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/logo_tontine.png',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Rejoignez la communauté Tontine-Manager',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildField(
          label: 'Nom complet',
          required: true,
          child: TextField(
            controller: _nomController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: 'Ex: Amadou Diop',
              icon: Icons.person_outline,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildField(
          label: 'Téléphone',
          required: true,
          child: IntlPhoneField(
            controller: _telephoneController,
            decoration: InputDecoration(
              hintText: 'Numéro de téléphone',
              hintStyle: TextStyle(color: AppColors.grey, fontSize: 16),
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            languageCode: 'fr',
            initialCountryCode: 'SN', // Sénégal par défaut
            dropdownIconPosition: IconPosition.trailing,
            flagsButtonPadding: const EdgeInsets.only(left: 8),
            dropdownIcon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.grey,
            ),
            onChanged: (phone) {
              setState(() {
                _completePhoneNumber = phone.completeNumber;
                try {
                  _isPhoneValid = phone.isValidNumber();
                } catch (_) {
                  _isPhoneValid = false;
                }
                _errorMessage = null;
              });
            },
            invalidNumberMessage: 'Numéro invalide',
          ),
        ),
        const SizedBox(height: 20),
        _buildField(
          label: 'Localité',
          required: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedLocalite,
                hint: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: AppColors.grey),
                    const SizedBox(width: 10),
                    Text(
                      'Sélectionnez votre ville',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                icon:
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
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
                onChanged: (val) => setState(() => _selectedLocalite = val),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildField(
          label: 'Code PIN',
          required: true,
          child: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (_) => setState(() => _pinMismatch = false),
            decoration: InputDecoration(
              hintText: '4 chiffres',
              hintStyle:
                  TextStyle(color: AppColors.grey, fontSize: 16),
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.grey, size: 20),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildField(
          label: 'Confirmer le code PIN',
          required: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _pinConfirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (_) => setState(() => _pinMismatch = false),
                decoration: InputDecoration(
                  hintText: 'Ressaisissez le code',
                  hintStyle:
                      TextStyle(color: AppColors.grey, fontSize: 16),
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _pinMismatch
                        ? const BorderSide(color: Colors.redAccent, width: 1.5)
                        : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: _pinMismatch
                        ? const BorderSide(color: Colors.redAccent, width: 1.5)
                        : BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.grey, size: 20),
                  counterText: '',
                ),
              ),
              if (_pinMismatch) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 14, color: Colors.redAccent),
                    SizedBox(width: 6),
                    Text(
                      'Les codes ne correspondent pas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isReady = _nomController.text.trim().isNotEmpty &&
        _isPhoneValid &&
        _completePhoneNumber.isNotEmpty &&
        _selectedLocalite != null &&
        _pinController.text.length == 4 &&
        _pinConfirmController.text.length == 4 &&
        !_isLoading;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isReady ? _submit : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'S\'inscrire',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Déjà un compte ? ',
          style: TextStyle(color: AppColors.grey, fontSize: 15),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ConnexionFullScreen()),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
          child: const Text(
            'Se connecter',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
      {required String label, required Widget child, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: AppColors.accent, fontSize: 14),
              ),
            ],
          ],
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
      hintStyle: TextStyle(color: AppColors.grey, fontSize: 16),
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
    );
  }
}
