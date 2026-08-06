import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import 'main_navigation_screen.dart';
import 'inscription_screen.dart';

class ConnexionFullScreen extends StatefulWidget {
  const ConnexionFullScreen({super.key});

  @override
  State<ConnexionFullScreen> createState() => _ConnexionFullScreenState();
}

class _ConnexionFullScreenState extends State<ConnexionFullScreen> {
  final _authService = AuthService();
  final _telephoneController = TextEditingController();
  String _pin = '';
  static const int _pinLength = 4;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  bool _showPinStep = false;

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength && !_isLoading) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin += digit;
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _validateLogin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty && !_isLoading) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  void _goToPinStep() {
    final phone = _telephoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Entrez votre numéro de téléphone';
      });
      return;
    }
    setState(() {
      _showPinStep = true;
      _isError = false;
    });
  }

  Future<void> _validateLogin() async {
    setState(() => _isLoading = true);

    final result = await _authService.connexion(
      telephone: _telephoneController.text.trim(),
      pin: _pin,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      SessionService().setCurrentUser(result.user!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      setState(() {
        _isError = true;
        _errorMessage = result.error!;
        _pin = '';
      });
    }
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: _showPinStep ? _buildPinStep() : _buildPhoneStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        _buildLogo(),
        const SizedBox(height: 24),
        const Text(
          'Connexion',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Entrez votre numéro de téléphone',
          style: TextStyle(fontSize: 15, color: AppColors.grey),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
            decoration: InputDecoration(
              hintText: '+221 7X XXX XX XX',
              hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryDark),
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
        if (_isError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToPinStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildFooter(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPinStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        _buildLogo(),
        const SizedBox(height: 20),
        const Text(
          'Code PIN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Entrez le PIN pour ${_telephoneController.text.trim()}',
          style: const TextStyle(fontSize: 15, color: AppColors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() {
            _showPinStep = false;
            _pin = '';
            _isError = false;
          }),
          child: const Text(
            'Changer de numéro',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildPinIndicators(),
        const SizedBox(height: 16),
        if (_isError)
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        const SizedBox(height: 32),
        _buildNumpad(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/logo_tontine.png',
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: isFilled ? 20 : 16,
          height: isFilled ? 20 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isError
                ? Colors.redAccent
                : isFilled
                    ? AppColors.primaryDark
                    : Colors.transparent,
            border: Border.all(
              color: _isError
                  ? Colors.redAccent
                  : isFilled
                      ? AppColors.primaryDark
                      : AppColors.grey.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumpadRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildNumpadRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildNumpadRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildNumpadRow(['', '0', 'del']),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 72, height: 72);
        }
        if (key == 'del') {
          return _buildDeleteKey();
        }
        return _buildDigitKey(key);
      }).toList(),
    );
  }

  Widget _buildDigitKey(String digit) {
    return GestureDetector(
      onTap: () => _onDigitPressed(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightGrey,
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 26,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pas de compte ? ',
              style: TextStyle(color: AppColors.grey, fontSize: 15),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InscriptionScreen(),
                  ),
                );
              },
              child: const Text(
                "S'inscrire",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
