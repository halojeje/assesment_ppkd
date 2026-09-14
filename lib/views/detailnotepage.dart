import 'package:assesment_ppkd/core/image_helper.dart';
import 'package:assesment_ppkd/model/note_model.dart';
import 'package:assesment_ppkd/providers/note_provider.dart';
import 'package:assesment_ppkd/views/editnotepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailNotePage extends StatefulWidget {
  final NoteModel note;

  const DetailNotePage({super.key, required this.note});

  @override
  State<DetailNotePage> createState() => _DetailNotePageState();
}

class _DetailNotePageState extends State<DetailNotePage> {
  late NoteModel _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  void _handleEdit() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(note: _currentNote),
      ),
    );

    if (updated == true && mounted) {
      setState(() {
        // Refreshed via Provider stream
      });
    }
  }

  void _handleDelete() {
    if (_currentNote.id == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text(
            'Apakah Anda yakin ingin menghapus catatan ${_currentNote.namaHewan}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final noteProvider =
                  Provider.of<NoteProvider>(context, listen: false);
              final success = await noteProvider.deleteNote(_currentNote.id!);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan berhasil dihapus!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createdDate = _currentNote.createdAt != null
        ? '${_currentNote.createdAt!.day}/${_currentNote.createdAt!.month}/${_currentNote.createdAt!.year} ${_currentNote.createdAt!.hour.toString().padLeft(2, '0')}:${_currentNote.createdAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: Text(
          _currentNote.namaHewan,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'Fraunces'),
        ),
        backgroundColor: const Color(0xFF5080E8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama
            if (_currentNote.fotoUrl != null &&
                _currentNote.fotoUrl!.isNotEmpty)
              ImageHelper.buildImage(
                _currentNote.fotoUrl,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentNote.namaHewan,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Fraunces',
                            color: Color(0xFF5080E8),
                          ),
                        ),
                      ),
                      if (createdDate.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            createdDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF5080E8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Details Informasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      _currentNote.details,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark
                            ? Colors.grey.shade200
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons (Edit & Delete)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleEdit,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit Catatan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5080E8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _handleDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Hapus',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
