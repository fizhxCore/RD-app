#!/usr/bin/env bash
# Dijalankan di CI setelah `flutter create --platforms=android .`
# Tujuannya: menambahkan permission & receiver yang dibutuhkan
# flutter_local_notifications + exact alarm scheduling, karena
# template default `flutter create` belum menyertakan ini.
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"

if [ ! -f "$MANIFEST" ]; then
  echo "AndroidManifest.xml tidak ditemukan di $MANIFEST, skip patch."
  exit 0
fi

# --- Tambahkan permission (jika belum ada) ---
add_permission() {
  local perm="$1"
  if ! grep -q "$perm" "$MANIFEST"; then
    sed -i "s#<manifest #<manifest #" "$MANIFEST" # no-op guard
    sed -i "0,/<application/s##<uses-permission android:name=\"$perm\" />\n    <application#" "$MANIFEST"
  fi
}

add_permission "android.permission.POST_NOTIFICATIONS"
add_permission "android.permission.SCHEDULE_EXACT_ALARM"
add_permission "android.permission.USE_EXACT_ALARM"
add_permission "android.permission.RECEIVE_BOOT_COMPLETED"
add_permission "android.permission.VIBRATE"

# --- Tambahkan receiver flutter_local_notifications (jika belum ada) ---
if ! grep -q "ScheduledNotificationReceiver" "$MANIFEST"; then
  python3 - "$MANIFEST" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

receivers = """
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
</application>"""

content = content.replace("</application>", receivers, 1)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("Receiver notifikasi berhasil ditambahkan ke AndroidManifest.xml")
PYEOF
fi

echo "Patch AndroidManifest.xml selesai."

# --- Pastikan minSdkVersion cukup tinggi & core library desugaring aktif ---
GRADLE_KTS="android/app/build.gradle.kts"
GRADLE_GROOVY="android/app/build.gradle"

patch_gradle() {
  local file="$1"
  if [ -f "$file" ]; then
    if ! grep -q "isCoreLibraryDesugaringEnabled" "$file"; then
      python3 - "$file" <<'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Aktifkan core library desugaring di compileOptions
content = re.sub(
    r"compileOptions\s*\{",
    "compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
    content,
    count=1,
)

# Tambahkan dependency desugaring jika belum ada
if "com.android.tools:desugar_jdk_libs" not in content:
    content = re.sub(
        r"dependencies\s*\{",
        'dependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")',
        content,
        count=1,
    )

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF
      echo "Patch $file untuk core library desugaring selesai."
    fi
  fi
}

patch_gradle "$GRADLE_KTS"
patch_gradle "$GRADLE_GROOVY"

echo "Patch Android selesai sepenuhnya."
