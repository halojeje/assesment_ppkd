import 'package:assesment_ppkd/core/image_helper.dart';
import 'package:assesment_ppkd/providers/auth_provider.dart';
import 'package:assesment_ppkd/providers/note_provider.dart';
import 'package:assesment_ppkd/views/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MainhomePage extends StatefulWidget {
  const MainhomePage({super.key});

  @override
  State<MainhomePage> createState() => _MainhomePageState();
}

class _MainhomePageState extends State<MainhomePage> {
  final TextEditingController _namaHewanController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _fotoUrlController = TextEditingController();

  String _selectedFotoUrl = 'dummy1.png';

  final List<String> _presetPhotos = [
    'dummy1.png',
    'dummy2.png',
    'dummy3.png',
    'dummy4.png',
    'dummy5.png',
  ];

  @override
  void dispose() {
    _namaHewanController.dispose();
    _detailsController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpan() async {
    final namaHewan = _namaHewanController.text.trim();
    final details = _detailsController.text.trim();
    final fotoUrl = _fotoUrlController.text.trim().isNotEmpty
        ? _fotoUrlController.text.trim()
        : _selectedFotoUrl;

    if (namaHewan.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lengkapi Nama Hewan dan Details Informasi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid ?? authProvider.user?.email;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final success = await noteProvider.addNote(
      namaHewan: namaHewan,
      details: details,
      fotoUrl: fotoUrl,
      customUserId: currentUserId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan $namaHewan berhasil disimpan!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Reset form
      _namaHewanController.clear();
      _detailsController.clear();
      _fotoUrlController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            noteProvider.errorMessage ?? 'Gagal menyimpan catatan.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery([BuildContext? modalCtx]) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedFotoUrl = pickedFile.path;
          _fotoUrlController.text = pickedFile.path;
        });
        if (modalCtx != null && Navigator.canPop(modalCtx)) {
          Navigator.pop(modalCtx);
        }
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

  void _handleUploadFoto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              const Text(
                'Pilih atau Upload Foto Hewan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Tombol Gallery Device
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImageFromGallery(ctx),
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
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = _presetPhotos[index];
                    final isSelected = _selectedFotoUrl == photo;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFotoUrl = photo;
                          _fotoUrlController.clear();
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF5080E8)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: getPetImage(photo),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context, rootNavigator: true);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              Navigator.pop(ctx);
              await authProvider.logout();

              if (!mounted) return;
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER (Profil & Logout) ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  final name = auth.user?.name.isNotEmpty == true
                      ? auth.user!.name
                      : (auth.user?.email.isNotEmpty == true
                          ? auth.user!.email.split('@').first
                          : 'User');
                  final email = auth.user?.email.isNotEmpty == true
                      ? auth.user!.email
                      : 'user@example.com';

                  return Row(
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF5080E8),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              getAvatarImage(auth.user?.profilePhoto),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Username & Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C84F6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : const Color(0xFF6E6E6E),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icon Logout Button
                      IconButton(
                        onPressed: _handleLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFD97757),
                          size: 28,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ---------------- CARD UTAMA (Biodata Hewan) ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black38
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Consumer<NoteProvider>(
                    builder: (context, noteProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biodata Hewan',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Fraunces',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input 1: Foto Hewan & Preview
                          // Input 1: Foto Hewan & Preview
                          _buildLabel('Foto Hewan'),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : const Color(0xFFD0D0D0),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Preview Foto (Kotak)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: ImageHelper.buildImage(
                                    _selectedFotoUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Tombol Upload berbentuk Pill
                                SizedBox(
                                  height: 32,
                                  child: OutlinedButton(
                                    onPressed: _handleUploadFoto,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFD0D0D0),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 0,
                                      ),
                                    ),
                                    child: Text(
                                      'Upload',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input 2: Nama Hewan
                          _buildLabel('Nama Hewan'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _namaHewanController,
                            hintText: 'Bonbon',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // Input 3: Details Informasi
                          _buildLabel('Details Informasi'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _detailsController,
                            hintText: 'Sehat dan semangat',
                            maxLines: 3,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 28),

                          // Tombol SIMPAN
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  noteProvider.isLoading ? null : _handleSimpan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5584E8),
                                elevation: 4,
                                shadowColor: const Color(
                                  0xFF5584E8,
                                ).withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: noteProvider.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'SIMPAN',
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    bool isDark = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF334155) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : const Color(0xFFD0D0D0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5584E8), width: 1.5),
        ),
      ),
    );
  }
}
