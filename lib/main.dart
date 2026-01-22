import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blue Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, 
          brightness: Brightness.light
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<Note>> notesList;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  void refreshNotes() {
    setState(() {
      notesList = DatabaseHelper.instance.readAllNotes();
    });
  }

  // Helper method to format date cleanly (e.g., "2023-10-25 14:30")
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LisNotes')),
      body: FutureBuilder<List<Note>>(
        future: notesList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada catatan!", 
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                color: Colors.blue.shade50,
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddNotePage(note: note),
                      ),
                    );
                    refreshNotes();
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.note, color: Colors.white),
                  ),
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      // DISPLAY TIMESTAMP HERE
                      Text(
                        formatDate(note.createdTime),
                        style: TextStyle(color: Colors.blue.shade800, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Catatan'),
                          content: const Text('Catatan yang dihapus tidak bisa dikembalikan!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && note.id != null) {
                        await DatabaseHelper.instance.delete(note.id!);
                        refreshNotes();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddNotePage()),
          );
          refreshNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddNotePage extends StatefulWidget {
  final Note? note;

  const AddNotePage({super.key, this.note});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id, 
        title: _titleController.text,
        content: _contentController.text,
        // IF CREATING: Use current time
        // IF EDITING: Keep the original time? Or update it? 
        // Logic below: We update the time to "now" whenever you save.
        createdTime: DateTime.now(), 
      );

      if (widget.note == null) {
        await DatabaseHelper.instance.create(note);
      } else {
        await DatabaseHelper.instance.update(note);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Buat Catatan' : 'Ubah Catatan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value!.isEmpty ? 'Harus ada judul' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Harus ada isi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.note == null ? 'Simpan Catatan' : 'Ubah Catatan', 
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}