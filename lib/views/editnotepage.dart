import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:assesment_ppkd/core/image_helper.dart';
import 'package:assesment_ppkd/model/note_model.dart';
import 'package:assesment_ppkd/providers/note_provider.dart';

class EditNotePage extends StatefulWidget {
  final NoteModel note;

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _namaHewanController;
  late TextEditingController _detailsController;
  late TextEditingController _fotoUrlController;
  late String _selectedFotoUrl;

  final List<String> _presetPhotos = [
    'dummy1.png',
    'dummy2.png',
    'dummy3.png',
    'dummy4.png',
    'dummy5.png',
  ];

  @override
  void initState() {
    super.initState();
    _namaHewanController = TextEditingController(text: widget.note.namaHewan);
    _detailsController = TextEditingController(text: widget.note.details);
    _fotoUrlController = TextEditingController(text: widget.note.fotoUrl ?? '');
    _selectedFotoUrl = widget.note.fotoUrl ?? _presetPhotos.first;
  }

  @override
  void dispose() {
    _namaHewanController.dispose();
    _detailsController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final namaHewan = _namaHewanController.text.trim();
    final details = _detailsController.text.trim();
    final fotoUrl = _fotoUrlController.text.trim().isNotEmpty
        ? _fotoUrlController.text.trim()
        : _selectedFotoUrl;

    if (namaHewan.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi Nama Hewan dan Details Informasi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.note.id == null) return;

    FocusScope.of(context).unfocus();

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final success = await noteProvider.updateNote(
      noteId: widget.note.id!,
      namaHewan: namaHewan,
      details: details,
      fotoUrl: fotoUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(noteProvider.errorMessage ?? 'Gagal memperbarui catatan.'),
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
            content: Text('Gagal memilih gambar dari galeri: $e'),
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
                'Pilih / Upload Foto Hewan',
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
                    side: const BorderSide(color: Color(0xFF5080E8), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Preset Foto:'),
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
                            color: isSelected ? const Color(0xFF5080E8) : Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text(
          'Edit Catatan Hewan',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Fraunces'),
        ),
        backgroundColor: const Color(0xFF5080E8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Preview
                  const Text('Foto Hewan', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImageHelper.buildImage(
                          _selectedFotoUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _handleUploadFoto,
                        icon: const Icon(Icons.photo_camera, size: 18),
                        label: const Text('Ganti Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5080E8),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Input Nama Hewan
                  const Text('Nama Hewan', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _namaHewanController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Details
                  const Text('Details Informasi', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _detailsController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tombol SIMPAN PERUBAHAN
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: noteProvider.isLoading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5080E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: noteProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SIMPAN PERUBAHAN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
    );
  }
}
