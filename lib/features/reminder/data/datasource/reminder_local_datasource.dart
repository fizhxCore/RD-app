import 'package:drift/drift.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/database/app_database.dart';

class ReminderLocalDataSource {
  ReminderLocalDataSource(this._db);
  final AppDatabase _db;

  Future<List<Reminder>> getAll() async {
    try {
      return await (_db.select(_db.reminders)
            ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
          .get();
    } catch (e) {
      throw const DatabaseException('Gagal memuat daftar reminder');
    }
  }

  Future<Reminder?> getById(int id) async {
    return (_db.select(_db.reminders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insert(RemindersCompanion entry) async {
    try {
      return await _db.into(_db.reminders).insert(entry);
    } catch (e) {
      throw const DatabaseException('Gagal menyimpan reminder');
    }
  }

  Future<void> update(int id, RemindersCompanion entry) async {
    try {
      await (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(entry);
    } catch (e) {
      throw const DatabaseException('Gagal memperbarui reminder');
    }
  }

  Future<void> deleteById(int id) async {
    await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
  }
}
