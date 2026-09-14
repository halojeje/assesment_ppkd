import 'package:assesment_ppkd/core/image_helper.dart';
import 'package:assesment_ppkd/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _noHpController;
  late TextEditingController _fotoUrlController;

  String? _lastLoadedUserId;

  final List<String> _presetAvatars = [
    'dummy1.png',
    'dummy2.png',
    'dummy3.png',
    'dummy4.png',
    'dummy5.png',
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _usernameController = TextEditingController(text: auth.user?.name ?? '');
    _emailController = TextEditingController(text: auth.user?.email ?? '');
    _noHpController = TextEditingController(text: auth.user?.phone ?? '');
    _fotoUrlController =
        TextEditingController(text: auth.user?.profilePhoto ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleEditProfile() async {
    final name = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _noHpController.text.trim();
    final profilePhoto = _fotoUrlController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Email tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserProfile(
      name: name,
      email: email,
      phone: phone,
      profilePhoto: profilePhoto,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil & Foto berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Gagal memperbarui profil.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAvatarFromGallery([BuildContext? modalCtx]) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _fotoUrlController.text = pickedFile.path;
        });
        if (modalCtx != null && Navigator.canPop(modalCtx)) {
          Navigator.pop(modalCtx);
        }
        await _handleEditProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto dari galeri: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleChangeAvatar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ganti Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Fraunces',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tombol Upload dari Galeri HP
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _pickAvatarFromGallery(ctx),
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF5080E8),
                  ),
                  label: const Text(
                    'Pilih Dari Galeri Device',
                    style: TextStyle(
                      color: Color(0xFF5080E8),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFF5080E8), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Pilih Foto Preset:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetAvatars.length,
                  itemBuilder: (context, index) {
                    final photo = _presetAvatars[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _fotoUrlController.text = photo;
                        });
                        Navigator.pop(ctx);
                        _handleEditProfile();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF5080E8), width: 2),
                          image: DecorationImage(
                            image: getAvatarImage(photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _fotoUrlController.clear();
                    });
                    Navigator.pop(ctx);
                    _handleEditProfile();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('Reset Foto Default'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Fraunces',
            fontSize: 28,
            color: isDark ? Colors.white : const Color(0xFF4A3E3D),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.user != null &&
                (_lastLoadedUserId != auth.user!.uid ||
                    (_usernameController.text.isEmpty &&
                        auth.user!.name.isNotEmpty))) {
              _lastLoadedUserId = auth.user!.uid;
              _usernameController.text = auth.user!.name;
              _emailController.text = auth.user!.email;
              _noHpController.text = auth.user!.phone ?? '';
              _fotoUrlController.text = auth.user!.profilePhoto ?? '';
            }

            final avatarImage = getAvatarImage(auth.user?.profilePhoto);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // Avatar Profil
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF5080E8),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: avatarImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _handleChangeAvatar,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5080E8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.user?.name.isNotEmpty == true
                        ? auth.user!.name
                        : 'Username',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Fraunces',
                    ),
                  ),
                  Text(
                    auth.user?.email.isNotEmpty == true
                        ? auth.user!.email
                        : 'email@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Input 1: Username
                  _buildLabel('Username', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _usernameController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Input 2: Email
                  _buildLabel('Email', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Input 3: No HP
                  _buildLabel('No HP', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),

                  // Tombol EDIT
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5584E8),
                        elevation: 4,
                        shadowColor:
                            const Color(0xFF5584E8).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'EDIT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isDark = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFD0D0D0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5584E8), width: 1.5),
        ),
      ),
    );
  }
}
