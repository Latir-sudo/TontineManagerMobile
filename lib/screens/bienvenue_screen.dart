import 'package:flutter/material.dart';
import 'connexion_full_screen.dart';
import 'inscription_screen.dart';

class BienvenueScreen extends StatelessWidget {
  const BienvenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Logo + nom de l'app
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo_tontine.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tontine ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Manager',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2B4403),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Titre principal
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Une meilleure\ngestion de vos tontines',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF070707),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sous-titre
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Rejoignez une grande communauté d\'épargne.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF534F4F),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Zone des avatars décoratifs
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      _buildAvatar(
                        constraints,
                        'assets/images/avatar1.png',
                        topFraction: 0.0,
                        leftFraction: 0.38,
                        size: 52,
                      ),
                      _buildAvatar(
                        constraints,
                        'assets/images/avatar2.png',
                        topFraction: 0.18,
                        leftFraction: 0.15,
                        size: 72,
                      ),
                      _buildAvatar(
                        constraints,
                        'assets/images/avatar3.png',
                        topFraction: 0.30,
                        leftFraction: 0.62,
                        size: 37,
                      ),
                      _buildAvatar(
                        constraints,
                        'assets/images/avatar4.png',
                        topFraction: 0.50,
                        leftFraction: 0.33,
                        size: 60,
                      ),
                      _buildAvatar(
                        constraints,
                        'assets/images/avatar5.png',
                        topFraction: 0.75,
                        leftFraction: 0.52,
                        size: 53,
                      ),
                    ],
                  );
                },
              ),
            ),
            // Boutons en bas
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InscriptionScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF2E4903),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFFF9F9F9),
                        ),
                        child: const Text(
                          'Ouvrir un compte',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E4903),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConnexionFullScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCEFA89),
                          foregroundColor: const Color(0xFF090909),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF090909),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(
    BoxConstraints constraints,
    String imagePath,
    {required double topFraction,
    required double leftFraction,
    required double size}
  ) {
    return Positioned(
      top: constraints.maxHeight * topFraction,
      left: constraints.maxWidth * leftFraction - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFE0E0E0),
                child: const Icon(Icons.person, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }
}
