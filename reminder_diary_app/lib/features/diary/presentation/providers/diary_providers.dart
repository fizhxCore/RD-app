import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/diary_entry_usecases.dart';
import '../../domain/usecases/diary_pin_usecases.dart';

final isPinSetUseCaseProvider = Provider((ref) => IsPinSet(ref.watch(diaryRepositoryProvider)));
final setupPinUseCaseProvider = Provider((ref) => SetupPin(ref.watch(diaryRepositoryProvider)));
final verifyPinUseCaseProvider = Provider((ref) => VerifyPin(ref.watch(diaryRepositoryProvider)));
final resetPinUseCaseProvider =
    Provider((ref) => ResetPinAndWipeData(ref.watch(diaryRepositoryProvider)));
final wipeForPinResetUseCaseProvider =
    Provider((ref) => WipeForPinReset(ref.watch(diaryRepositoryProvider)));

final addDiaryEntryUseCaseProvider =
    Provider((ref) => AddDiaryEntry(ref.watch(diaryRepositoryProvider)));
final updateDiaryEntryUseCaseProvider =
    Provider((ref) => UpdateDiaryEntry(ref.watch(diaryRepositoryProvider)));
final deleteDiaryEntryUseCaseProvider =
    Provider((ref) => DeleteDiaryEntry(ref.watch(diaryRepositoryProvider)));

/// Status kunci diary untuk sesi berjalan saat ini. TIDAK dipersist —
/// setiap kali tab Diary dibuka ulang / app kembali dari background,
/// harus verifikasi PIN lagi (auto-lock by design).
class DiaryLockNotifier extends Notifier<bool> {
  @override
  bool build() => true; // true = terkunci

  void unlock() => state = false;
  void lock() => state = true;
}

final diaryLockProvider = NotifierProvider<DiaryLockNotifier, bool>(
  DiaryLockNotifier.new,
);

class DiaryListNotifier extends AsyncNotifier<List<DiaryEntry>> {
  @override
  Future<List<DiaryEntry>> build() {
    return ref.watch(diaryRepositoryProvider).getAllEntries();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(diaryRepositoryProvider).getAllEntries(),
    );
  }

  Future<void> add(DiaryEntry entry) async {
    await ref.read(addDiaryEntryUseCaseProvider).call(entry);
    await refresh();
  }

  Future<void> edit(DiaryEntry entry) async {
    await ref.read(updateDiaryEntryUseCaseProvider).call(entry);
    await refresh();
  }

  Future<void> remove(int id) async {
    await ref.read(deleteDiaryEntryUseCaseProvider).call(id);
    await refresh();
  }
}

final diaryListProvider = AsyncNotifierProvider<DiaryListNotifier, List<DiaryEntry>>(
  DiaryListNotifier.new,
);
