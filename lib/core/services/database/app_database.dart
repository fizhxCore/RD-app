import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../constants/app_constants.dart';

part 'app_database.g.dart';

/// Tabel reminder utama. Menyimpan semua data reminder non-diary.
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueAt => dateTime()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get category => text().withDefault(const Constant('Umum'))();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF6C63FF))();
  TextColumn get repeatType => text().withDefault(const Constant('none'))();
  TextColumn get preReminder => text().withDefault(const Constant('onTime'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  // ID notifikasi yang sedang aktif dijadwalkan untuk reminder ini,
  // dipakai supaya bisa dibatalkan/reschedule dengan tepat.
  IntColumn get activeNotificationId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tabel diary. content disimpan sudah terenkripsi (base64 ciphertext),
/// bukan plaintext, sehingga bocor database saja tidak cukup untuk membaca isi.
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get contentEncrypted => text()();
  TextColumn get contentIv => text()(); // IV per-entry untuk AES-CBC
  TextColumn get category => text().withDefault(const Constant('Umum'))();
  TextColumn get mood => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Reminders, DiaryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbFileName));
    return NativeDatabase.createInBackground(file);
  });
}
