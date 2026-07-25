import '../../../../core/services/database/app_database.dart' as db;
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasource/diary_local_datasource.dart';
import '../services/diary_encryption_service.dart';
import '../services/pin_service.dart';

/// Menjembatani domain (plaintext DiaryEntry) dengan data layer
/// (ciphertext di database). Semua enkripsi/dekripsi terjadi di sini
/// supaya use case & UI tidak pernah perlu tahu detail kriptografi.
class DiaryRepositoryImpl implements DiaryRepository {
  DiaryRepositoryImpl({
    required DiaryLocalDataSource localDataSource,
    required DiaryEncryptionService encryptionService,
    required PinService pinService,
  })  : _local = localDataSource,
        _encryption = encryptionService,
        _pin = pinService;

  final DiaryLocalDataSource _local;
  final DiaryEncryptionService _encryption;
  final PinService _pin;

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    final rows = await _local.getAll();
    final entries = <DiaryEntry>[];
    for (final row in rows) {
      final plain = await _encryption.decrypt(row.contentEncrypted, row.contentIv);
      entries.add(_toEntity(row, plain));
    }
    return entries;
  }

  @override
  Future<DiaryEntry?> getEntryById(int id) async {
    final row = await _local.getById(id);
    if (row == null) return null;
    final plain = await _encryption.decrypt(row.contentEncrypted, row.contentIv);
    return _toEntity(row, plain);
  }

  @override
  Future<int> addEntry(DiaryEntry entry) async {
    final payload = await _encryption.encrypt(entry.content);
    return _local.insert(db.DiaryEntriesCompanion.insert(
      title: entry.title,
      contentEncrypted: payload.cipherText,
      contentIv: payload.iv,
      category: db.Value(entry.category),
      mood: db.Value(entry.mood),
    ));
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    final payload = await _encryption.encrypt(entry.content);
    await _local.update(
      entry.id!,
      db.DiaryEntriesCompanion(
        title: db.Value(entry.title),
        contentEncrypted: db.Value(payload.cipherText),
        contentIv: db.Value(payload.iv),
        category: db.Value(entry.category),
        mood: db.Value(entry.mood),
        updatedAt: db.Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteEntry(int id) => _local.deleteById(id);

  @override
  Future<bool> isPinSet() => _pin.isPinSet();

  @override
  Future<void> setupPin(String pin) async {
    await _pin.setPin(pin);
    await _encryption.generateKeyFromPin(pin);
  }

  @override
  Future<bool> verifyPin(String pin) => _pin.verifyPin(pin);

  @override
  Future<void> resetPinAndWipeData(String newPin) async {
    await _pin.clearPin();
    await _local.deleteAll();
    await setupPin(newPin);
  }

  @override
  Future<void> wipeForPinReset() async {
    await _pin.clearPin();
    await _local.deleteAll();
  }

  DiaryEntry _toEntity(db.DiaryEntry row, String plainContent) {
    return DiaryEntry(
      id: row.id,
      title: row.title,
      content: plainContent,
      category: row.category,
      mood: row.mood,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
