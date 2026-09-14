import 'package:assesment_ppkd/core/image_helper.dart';
import 'package:assesment_ppkd/model/note_model.dart';
import 'package:assesment_ppkd/providers/auth_provider.dart';
import 'package:assesment_ppkd/providers/note_provider.dart';
import 'package:assesment_ppkd/views/detailnotepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListNotesPage extends StatefulWidget {
  const ListNotesPage({super.key});

  @override
  State<ListNotesPage> createState() => _ListNotesPageState();
}

class _ListNotesPageState extends State<ListNotesPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.user?.uid ?? auth.user?.email ?? '';
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF8F5),
      appBar: AppBar(
        title: const Text(
          'List Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Fraunces',
            fontSize: 28,
            color: Color(0xFF4A3E3D),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: noteProvider.getNotesStreamForUser(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5080E8)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan memuat data: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_outlined,
                        size: 64,
                        color: Color(0xFF5080E8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Belum Ada Catatan Hewan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Fraunces',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan biodata dan catatan hewan kesayangan Anda pada menu Beranda (Home).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _buildNoteCard(note, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : const Color(0xFFDCD6CD),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailNotePage(note: note),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Gambar/Thumbnail persegi kecil di sebelah kiri
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: ImageHelper.buildImage(
                    note.fotoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),

                // Nama Hewan & Details Informasi (2 Baris)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        note.namaHewan,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (note.details.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note.details,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
