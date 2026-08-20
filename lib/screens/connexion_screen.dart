import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../services/push_notification_service.dart';
import 'main_navigation_screen.dart';
import 'inscription_screen.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({super.key});

  @override
  State<ConnexionScreen> createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _authService = AuthService();
  String _pin = '';
  static const int _pinLength = 4;
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength && !_isLoading) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin += digit;
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _validatePin();
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

  Future<void> _validatePin() async {
    setState(() => _isLoading = true);

    final result = await _authService.connexionParPin(pin: _pin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      SessionService().setCurrentUser(result.user!);
      PushNotificationService().verifierEtEnvoyerRappels();
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
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
                _buildFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/logo_tontine.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Bon retour !',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Entrez votre code PIN',
          style: TextStyle(fontSize: 15, color: AppColors.grey),
        ),
      ],
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
        decoration: BoxDecoration(
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
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Code oublié ?',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
