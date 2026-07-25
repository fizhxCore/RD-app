import 'package:drift/drift.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/services/database/app_database.dart';

/// Datasource murni CRUD ke tabel DiaryEntries. Tidak tahu apa-apa soal
/// enkripsi — dia hanya menyimpan/membaca string ciphertext apa adanya.
/// Enkripsi/dekripsi jadi tanggung jawab repository.
class DiaryLocalDataSource {
  DiaryLocalDataSource(this._db);
  final AppDatabase _db;

  Future<List<DiaryEntry>> getAll() async {
    try {
      return await (_db.select(_db.diaryEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
    } catch (e) {
      throw const DatabaseException('Gagal memuat daftar catatan diary');
    }
  }

  Future<DiaryEntry?> getById(int id) async {
    return (_db.select(_db.diaryEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insert(DiaryEntriesCompanion entry) async {
    try {
      return await _db.into(_db.diaryEntries).insert(entry);
    } catch (e) {
      throw const DatabaseException('Gagal menyimpan catatan diary');
    }
  }

  Future<void> update(int id, DiaryEntriesCompanion entry) async {
    try {
      await (_db.update(_db.diaryEntries)..where((t) => t.id.equals(id)))
          .write(entry);
    } catch (e) {
      throw const DatabaseException('Gagal memperbarui catatan diary');
    }
  }

  Future<void> deleteById(int id) async {
    await (_db.delete(_db.diaryEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Dipakai saat reset PIN — menghapus SEMUA entry karena tidak bisa
  /// didekripsi lagi tanpa PIN/key lama.
  Future<void> deleteAll() async {
    await _db.delete(_db.diaryEntries).go();
  }
}
