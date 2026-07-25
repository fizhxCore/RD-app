import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getAllEntries();
  Future<DiaryEntry?> getEntryById(int id);
  Future<int> addEntry(DiaryEntry entry);
  Future<void> updateEntry(DiaryEntry entry);
  Future<void> deleteEntry(int id);

  Future<bool> isPinSet();
  Future<void> setupPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> resetPinAndWipeData(String newPin);
  Future<void> wipeForPinReset();
}
