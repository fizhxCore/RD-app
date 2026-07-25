import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class GetAllDiaryEntries {
  const GetAllDiaryEntries(this._repository);
  final DiaryRepository _repository;
  Future<List<DiaryEntry>> call() => _repository.getAllEntries();
}

class AddDiaryEntry {
  const AddDiaryEntry(this._repository);
  final DiaryRepository _repository;
  Future<int> call(DiaryEntry entry) => _repository.addEntry(entry);
}

class UpdateDiaryEntry {
  const UpdateDiaryEntry(this._repository);
  final DiaryRepository _repository;
  Future<void> call(DiaryEntry entry) => _repository.updateEntry(entry);
}

class DeleteDiaryEntry {
  const DeleteDiaryEntry(this._repository);
  final DiaryRepository _repository;
  Future<void> call(int id) => _repository.deleteEntry(id);
}
