import '../repositories/diary_repository.dart';

class IsPinSet {
  const IsPinSet(this._repository);
  final DiaryRepository _repository;
  Future<bool> call() => _repository.isPinSet();
}

class SetupPin {
  const SetupPin(this._repository);
  final DiaryRepository _repository;
  Future<void> call(String pin) => _repository.setupPin(pin);
}

class VerifyPin {
  const VerifyPin(this._repository);
  final DiaryRepository _repository;
  Future<bool> call(String pin) => _repository.verifyPin(pin);
}

/// Reset PIN = wipe semua data diary lama (lihat catatan trade-off
/// di PinService). UI WAJIB menampilkan konfirmasi tegas sebelum
/// use case ini dipanggil.
class ResetPinAndWipeData {
  const ResetPinAndWipeData(this._repository);
  final DiaryRepository _repository;
  Future<void> call(String newPin) => _repository.resetPinAndWipeData(newPin);
}

/// Menghapus PIN lama & semua data diary TANPA langsung mengatur PIN baru.
/// Dipakai di alur "Lupa PIN" — setelah ini, user diarahkan ke PinSetupPage
/// untuk membuat PIN baru dari nol.
class WipeForPinReset {
  const WipeForPinReset(this._repository);
  final DiaryRepository _repository;
  Future<void> call() => _repository.wipeForPinReset();
}
