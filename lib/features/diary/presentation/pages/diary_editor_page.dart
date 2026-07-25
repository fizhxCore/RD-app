import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class DiaryEditorPage extends ConsumerStatefulWidget {
  const DiaryEditorPage({super.key, this.existing});
  final DiaryEntry? existing;

  @override
  ConsumerState<DiaryEditorPage> createState() => _DiaryEditorPageState();
}

class _DiaryEditorPageState extends ConsumerState<DiaryEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late String _category;
  String? _mood;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _contentCtrl = TextEditingController(text: e?.content ?? '');
    _category = e?.category ?? 'Umum';
    _mood = e?.mood;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();

    final entry = DiaryEntry(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      category: _category,
      mood: _mood,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(diaryListProvider.notifier);
    if (_isEditing) {
      await notifier.edit(entry);
    } else {
      await notifier.add(entry);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    const moods = ['😊', '😐', '😢', '😡', '😴', '🥰'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Catatan' : 'Catatan Baru'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(hintText: 'Judul catatan', border: InputBorder.none),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: moods.map((m) {
                final selected = _mood == m;
                return ChoiceChip(
                  label: Text(m, style: const TextStyle(fontSize: 18)),
                  selected: selected,
                  onSelected: (_) => setState(() => _mood = selected ? null : m),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              onChanged: (v) => _category = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentCtrl,
              minLines: 8,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Tulis apa yang kamu rasakan hari ini…',
                border: InputBorder.none,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi catatan tidak boleh kosong' : null,
            ),
          ],
        ),
      ),
    );
  }
}
