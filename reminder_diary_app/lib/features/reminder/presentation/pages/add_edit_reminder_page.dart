import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_providers.dart';

/// Satu halaman dipakai untuk Tambah & Edit (dibedakan lewat [existing]),
/// supaya tidak ada duplikasi form antara dua alur yang sebenarnya identik.
class AddEditReminderPage extends ConsumerStatefulWidget {
  const AddEditReminderPage({super.key, this.existing});
  final ReminderEntity? existing;

  @override
  ConsumerState<AddEditReminderPage> createState() => _AddEditReminderPageState();
}

class _AddEditReminderPageState extends ConsumerState<AddEditReminderPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _dateTime;
  late ReminderPriority _priority;
  late String _category;
  late RepeatType _repeat;
  late PreReminderOption _preReminder;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _dateTime = e?.dateTime ?? DateTime.now().add(const Duration(minutes: 30));
    _priority = e?.priority ?? ReminderPriority.medium;
    _category = e?.category ?? 'Umum';
    _repeat = e?.repeatType ?? RepeatType.none;
    _preReminder = e?.preReminder ?? PreReminderOption.onTime;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _dateTime = DateTime(picked.year, picked.month, picked.day, _dateTime.hour, _dateTime.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked != null) {
      setState(() {
        _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final entity = ReminderEntity(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      dateTime: _dateTime,
      priority: _priority,
      category: _category,
      repeatType: _repeat,
      preReminder: _preReminder,
      isCompleted: widget.existing?.isCompleted ?? false,
      activeNotificationId: widget.existing?.activeNotificationId,
    );

    final notifier = ref.read(reminderListProvider.notifier);
    if (_isEditing) {
      await notifier.edit(entity);
    } else {
      await notifier.add(entity);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Reminder' : 'Tambah Reminder')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(DateFormat('d MMM yyyy').format(_dateTime)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(DateFormat('HH:mm').format(_dateTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<ReminderPriority>(
              segments: const [
                ButtonSegment(value: ReminderPriority.low, label: Text('Rendah')),
                ButtonSegment(value: ReminderPriority.medium, label: Text('Sedang')),
                ButtonSegment(value: ReminderPriority.high, label: Text('Tinggi')),
              ],
              selected: {_priority},
              onSelectionChanged: (v) => setState(() => _priority = v.first),
            ),
            const SizedBox(height: 18),
            TextFormField(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              onChanged: (v) => _category = v,
            ),
            const SizedBox(height: 18),
            const Text('Ulangi', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<RepeatType>(
              initialValue: _repeat,
              items: const [
                DropdownMenuItem(value: RepeatType.none, child: Text('Tidak berulang')),
                DropdownMenuItem(value: RepeatType.daily, child: Text('Harian')),
                DropdownMenuItem(value: RepeatType.weekly, child: Text('Mingguan')),
                DropdownMenuItem(value: RepeatType.monthly, child: Text('Bulanan')),
              ],
              onChanged: (v) => setState(() => _repeat = v ?? RepeatType.none),
            ),
            const SizedBox(height: 18),
            const Text('Ingatkan', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<PreReminderOption>(
              initialValue: _preReminder,
              items: PreReminderOption.values
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                  .toList(),
              onChanged: (v) => setState(() => _preReminder = v ?? PreReminderOption.onTime),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
