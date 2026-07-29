import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MembresTontineScreen extends StatefulWidget {
  const MembresTontineScreen({super.key});

  @override
  State<MembresTontineScreen> createState() => _MembresTontineScreenState();
}

class _MembresTontineScreenState extends State<MembresTontineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _membres = [
    {
      'prenom': 'Fatou',
      'nom': 'Badji',
      'telephone': '+221 77 123 45 67',
      'photoUrl': null,
      'isAdmin': true,
      'isOnline': true,
    },
    {
      'prenom': 'Moussa',
      'nom': 'Diallo',
      'telephone': '+221 78 234 56 78',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
    {
      'prenom': 'Khadija',
      'nom': 'Sow',
      'telephone': '+221 76 345 67 89',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Ibrahima',
      'nom': 'Ndiaye',
      'telephone': '+221 77 456 78 90',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
    {
      'prenom': 'Aminata',
      'nom': 'Fall',
      'telephone': '+221 70 567 89 01',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Ousmane',
      'nom': 'Ba',
      'telephone': '+221 78 678 90 12',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Mariama',
      'nom': 'Diop',
      'telephone': '+221 76 789 01 23',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
    {
      'prenom': 'Abdoulaye',
      'nom': 'Sarr',
      'telephone': '+221 77 890 12 34',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Aïssatou',
      'nom': 'Gueye',
      'telephone': '+221 70 901 23 45',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
    {
      'prenom': 'Mamadou',
      'nom': 'Sy',
      'telephone': '+221 78 012 34 56',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Ndèye',
      'nom': 'Mbaye',
      'telephone': '+221 76 123 45 67',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
    {
      'prenom': 'Cheikh',
      'nom': 'Thiam',
      'telephone': '+221 77 234 56 78',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Sokhna',
      'nom': 'Dieng',
      'telephone': '+221 70 345 67 89',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
    {
      'prenom': 'Pape',
      'nom': 'Faye',
      'telephone': '+221 78 456 78 90',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': false,
    },
    {
      'prenom': 'Dieynaba',
      'nom': 'Kane',
      'telephone': '+221 76 567 89 01',
      'photoUrl': null,
      'isAdmin': false,
      'isOnline': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredMembres {
    if (_searchQuery.isEmpty) return _membres;
    final query = _searchQuery.toLowerCase();
    return _membres.where((m) {
      final fullName = '${m['prenom']} ${m['nom']}'.toLowerCase();
      final phone = (m['telephone'] as String).replaceAll(' ', '');
      return fullName.contains(query) || phone.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildMemberCount(),
            Expanded(child: _buildMembersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.white, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Membres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.groups_rounded,
                        color: AppColors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_membres.length}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 44),
              Text(
                'Epargne solidaire',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Rechercher un membre...',
            hintStyle: TextStyle(
              color: AppColors.grey.withValues(alpha: 0.8),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.grey.withValues(alpha: 0.8),
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.grey, size: 20),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCount() {
    final onlineCount = _filteredMembres.where((m) => m['isOnline']).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Text(
            '${_filteredMembres.length} membre${_filteredMembres.length > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$onlineCount en ligne',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    final membres = _filteredMembres;

    if (membres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded,
                size: 56, color: AppColors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Aucun membre trouvé',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final admin = membres.where((m) => m['isAdmin']).toList();
    final others = membres.where((m) => !m['isAdmin']).toList();
    final sortedMembres = [...admin, ...others];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: sortedMembres.length,
      itemBuilder: (context, index) {
        final membre = sortedMembres[index];
        final isLast = index == sortedMembres.length - 1;
        return _buildMembreItem(membre, isLast);
      },
    );
  }

  Widget _buildMembreItem(Map<String, dynamic> membre, bool isLast) {
    final String prenom = membre['prenom'];
    final String nom = membre['nom'];
    final String telephone = membre['telephone'];
    final bool isAdmin = membre['isAdmin'];
    final bool isOnline = membre['isOnline'];
    final String? photoUrl = membre['photoUrl'];
    final String initials = '${prenom[0]}${nom[0]}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showMembreBottomSheet(membre),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: photoUrl != null
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _getAvatarGradient(prenom),
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: _getAvatarGradient(prenom)[0]
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '$prenom $nom',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: AppColors.grey.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            telephone,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey.withValues(alpha: 0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMembreBottomSheet(Map<String, dynamic> membre) {
    final String prenom = membre['prenom'];
    final String nom = membre['nom'];
    final String telephone = membre['telephone'];
    final bool isAdmin = membre['isAdmin'];
    final String initials = '${prenom[0]}${nom[0]}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getAvatarGradient(prenom),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _getAvatarGradient(prenom)[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$prenom $nom',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Administrateur',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.phone_rounded,
                        color: AppColors.primaryDark, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Téléphone',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        telephone,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: 'Appeler',
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.message_rounded,
                    label: 'Message',
                    color: AppColors.primaryDark,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getAvatarGradient(String name) {
    final gradients = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
      [const Color(0xFFFCCB90), const Color(0xFFD57EEB)],
      [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
    ];
    final index = name.codeUnitAt(0) % gradients.length;
    return gradients[index];
  }
}
