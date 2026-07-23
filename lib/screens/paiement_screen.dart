import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaiementScreen extends StatefulWidget {
  const PaiementScreen({super.key});

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  String _selectedMethod = 'wave';
  final _phoneController = TextEditingController(text: '7754365435');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
              _buildHeader(context),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choisir un mode de paiement sécurisé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentOptionWave(),
                    const SizedBox(height: 12),
                    _buildPaymentOptionOrangeMoney(),
                    const SizedBox(height: 32),
                    const Text(
                      'Numéro Téléphone',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_android,
                              color: AppColors.grey, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 17,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Vous recevrez une notification pour confirmer le paiement',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.grey.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showPaymentConfirmation(context);
                        },
                        child: const Text('Payer'),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios,
                    color: AppColors.darkText, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('💰', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Effectuer son paiement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Montant à payer',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '5000 FCFA',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tontine famille',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Mai 2026',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionWave() {
    final isSelected = _selectedMethod == 'wave';
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = 'wave'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4DC9F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const _WaveLogo(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wave',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Paiement mobile',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionOrangeMoney() {
    final isSelected = _selectedMethod == 'orange_money';
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = 'orange_money'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryDark
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const _OrangeMoneyLogo(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Orange Money',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Paiement mobile',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            _buildRadio(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primaryDark : AppColors.grey,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
              ),
            )
          : null,
    );
  }

  void _showPaymentConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paiement en cours de traitement...'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }
}

class _WaveLogo extends StatelessWidget {
  const _WaveLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveLogoPainter(),
    );
  }
}

class _WaveLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Body (black penguin shape)
    final bodyPaint = Paint()..color = Colors.black;
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(
      center: Offset(cx, cy + 2),
      width: size.width * 0.6,
      height: size.height * 0.7,
    ));
    // Head
    bodyPath.addOval(Rect.fromCenter(
      center: Offset(cx, cy - size.height * 0.18),
      width: size.width * 0.42,
      height: size.height * 0.35,
    ));
    canvas.drawPath(bodyPath, bodyPaint);

    // White belly
    final bellyPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 4),
        width: size.width * 0.32,
        height: size.height * 0.4,
      ),
      bellyPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 4, cy - size.height * 0.18), 2.5, eyePaint);
    canvas.drawCircle(Offset(cx + 4, cy - size.height * 0.18), 2.5, eyePaint);

    // Beak (orange)
    final beakPaint = Paint()..color = const Color(0xFFFF8C00);
    final beakPath = Path();
    beakPath.moveTo(cx - 3, cy - size.height * 0.12);
    beakPath.lineTo(cx + 3, cy - size.height * 0.12);
    beakPath.lineTo(cx, cy - size.height * 0.07);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    // Feet (orange)
    final feetPaint = Paint()..color = const Color(0xFFFF8C00);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 5, cy + size.height * 0.35),
        width: 8,
        height: 4,
      ),
      feetPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 5, cy + size.height * 0.35),
        width: 8,
        height: 4,
      ),
      feetPaint,
    );

    // Waving arm (left)
    final armPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final armPath = Path();
    armPath.moveTo(cx - size.width * 0.18, cy);
    armPath.quadraticBezierTo(
      cx - size.width * 0.35,
      cy - size.height * 0.15,
      cx - size.width * 0.28,
      cy - size.height * 0.25,
    );
    canvas.drawPath(armPath, armPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrangeMoneyLogo extends StatelessWidget {
  const _OrangeMoneyLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OrangeMoneyLogoPainter(),
    );
  }
}

class _OrangeMoneyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // White arrow (pointing up-right)
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final whiteArrow = Path();
    // Arrow shaft going up-right
    whiteArrow.moveTo(cx - 10, cy + 8);
    whiteArrow.lineTo(cx - 6, cy + 8);
    whiteArrow.lineTo(cx + 2, cy - 4);
    // Arrow head
    whiteArrow.lineTo(cx + 2, cy + 2);
    whiteArrow.lineTo(cx + 6, cy + 2);
    whiteArrow.lineTo(cx + 6, cy - 10);
    whiteArrow.lineTo(cx - 2, cy - 10);
    whiteArrow.lineTo(cx - 2, cy - 6);
    whiteArrow.lineTo(cx - 6, cy + 4);
    whiteArrow.lineTo(cx - 10, cy + 4);
    whiteArrow.close();
    canvas.drawPath(whiteArrow, whitePaint);

    // Orange arrow (pointing down-left)
    final orangePaint = Paint()
      ..color = const Color(0xFFFF8C00)
      ..style = PaintingStyle.fill;

    final orangeArrow = Path();
    orangeArrow.moveTo(cx + 10, cy - 6);
    orangeArrow.lineTo(cx + 6, cy - 6);
    orangeArrow.lineTo(cx - 2, cy + 6);
    // Arrow head
    orangeArrow.lineTo(cx - 2, cy);
    orangeArrow.lineTo(cx - 6, cy);
    orangeArrow.lineTo(cx - 6, cy + 12);
    orangeArrow.lineTo(cx + 2, cy + 12);
    orangeArrow.lineTo(cx + 2, cy + 8);
    orangeArrow.lineTo(cx + 6, cy - 2);
    orangeArrow.lineTo(cx + 10, cy - 2);
    orangeArrow.close();
    canvas.drawPath(orangeArrow, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
