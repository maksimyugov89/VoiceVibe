import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_theme.dart' as app_theme;
import '../constants/strings.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _textController = TextEditingController(text: widget.note.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.titleCannotBeEmpty)),
      );
      return;
    }
    final updatedNote = Note(
      path: widget.note.path,
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      date: widget.note.date,
    );
    Navigator.pop(context, updatedNote);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(Strings.editNoteTitle),
        backgroundColor: isDark ? app_theme.VoiceVibeTheme.surfaceDark : Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded, size: 28),
            onPressed: _onSave,
            tooltip: Strings.save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(app_theme.VoiceVibeTheme.space16),
        child: Column(
          children: [
            // ПОЛЕ ДЛЯ ЗАГОЛОВКА (сверху)
            TextField(
              controller: _titleController,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: Strings.noteTitleHint,
                border: InputBorder.none,
                hintStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            
            const Divider(height: 24),
            
            // ПОЛЕ ДЛЯ ТЕКСТА (снизу, большое)
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                decoration: InputDecoration(
                  hintText: Strings.noteTextHint,
                  border: InputBorder.none,
                   hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}