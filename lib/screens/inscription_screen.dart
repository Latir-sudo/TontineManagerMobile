import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/push_notification_service.dart';
import 'connexion_full_screen.dart';
import 'main_navigation_screen.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _authService = AuthService();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _cniController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  bool _pinMismatch = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedLocalite;
  File? _cniImage;

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
    _cniController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  Future<void> _pickCniImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _cniImage = File(picked.path));
    }
  }

  Future<String?> _uploadCniImage(String uid) async {
    if (_cniImage == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('cni_images')
        .child('$uid.jpg');
    await ref.putFile(_cniImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (_nomController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir les champs obligatoires');
      return;
    }

    if (_cniController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Le numéro CNI est obligatoire');
      return;
    }

    if (_cniImage == null) {
      setState(() => _errorMessage = 'Veuillez ajouter une photo de votre CNI');
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

    try {
      // 1. D'abord créer le compte pour obtenir le uid
      final result = await _authService.inscription(
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        localite: _selectedLocalite ?? '',
        pin: _pinController.text,
        numeroCni: _cniController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // 2. Upload de l'image CNI vers Firebase Storage
        final imageUrl = await _uploadCniImage(result.user!.uid);

        // 3. Mettre à jour le profil avec l'URL de l'image
        if (imageUrl != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(result.user!.uid)
              .update({'cniImageUrl': imageUrl});
        }

        if (!mounted) return;
        SessionService().setCurrentUser(result.user!);
        PushNotificationService().verifierEtEnvoyerRappels();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.error;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de l\'envoi de l\'image. Réessayez.';
      });
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
          child: TextField(
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hint: '77 123 45 67',
              icon: Icons.phone_outlined,
            ),
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
          label: 'Numéro CNI',
          required: true,
          child: TextField(
            controller: _cniController,
            keyboardType: TextInputType.text,
            decoration: _inputDecoration(
              hint: 'Ex: 1 234 5678 90123',
              icon: Icons.badge_outlined,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildField(
          label: 'Photo de la CNI',
          required: true,
          child: GestureDetector(
            onTap: _pickCniImage,
            child: Container(
              width: double.infinity,
              height: _cniImage != null ? 200 : 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: _cniImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _cniImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _cniImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 36,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Appuyez pour ajouter une photo',
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Photo recto de votre carte d\'identité',
                          style: TextStyle(
                            color: AppColors.grey.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
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
    final isReady = _pinController.text.length == 4 &&
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
