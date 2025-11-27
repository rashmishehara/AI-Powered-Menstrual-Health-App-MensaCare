import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;
  Database get db => _db!;

  static const _dbName = 'mensacare.db';
  static const _dbVersion = 1;

  Future<void> init({String? dbPath}) async {
    if (_db == null) {
      if (dbPath == null) {
        final dir = await getApplicationDocumentsDirectory();
        dbPath = p.join(dir.path, _dbName);
      }
      _db = await openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: (d, v) async {
          await _createV1(d);
        },
        onUpgrade: (d, oldV, newV) async {
          // handle future migrations
        },
      );
    }
    // Ensure typed symptoms table exists even on already-initialized DBs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS symptoms_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        sleep_hours TEXT,
        weight_change TEXT,
        smoking_alcohol INTEGER,
        birth_control_use INTEGER,
        hair_loss INTEGER,
        acne INTEGER,
        fatigue INTEGER,
        bloating INTEGER,
        nausea INTEGER,
        dizziness INTEGER,
        hot_flashes INTEGER,
        irritability INTEGER,
        forgetfulness INTEGER,
        depression INTEGER,
        tension INTEGER,
        social_withdrawal INTEGER,
        headache INTEGER,
        lower_back_pain INTEGER,
        pain_during_sex INTEGER,
        flow INTEGER,
        pelvic_pain INTEGER,
        stress INTEGER,
        created_at INTEGER,
        UNIQUE(user_id, log_date),
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    ''');
    // Ensure app flags table exists for simple key-value booleans
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_flags (
        key TEXT PRIMARY KEY,
        value TEXT
      );
    ''');
    // Ensure model predictions table exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS model_predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        model_name TEXT,
        window_start TEXT,
        window_end TEXT,
        output_json TEXT,
        created_at INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    ''');
    // Ensure cycles table exists for analysis
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cycles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        first_day TEXT NOT NULL,         -- YYYY-MM-DD
        period_length INTEGER NOT NULL,  -- days bleeding
        cycle_length INTEGER NOT NULL,   -- days between period starts
        created_at INTEGER,
        UNIQUE(user_id, first_day),
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    ''');
    // Deduplicate any existing rows before creating unique index
    await _dedupeModelPredictions();
    // Ensure uniqueness per (user, model, window)
    try {
      await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_model_predictions_unique ON model_predictions(user_id, model_name, window_start, window_end)');
    } catch (_) {
      // Ignore if creation fails due to older SQLite behavior; table remains usable.
    }
  }

  // App flags helpers
  Future<void> setAppFlag({required String key, required bool value}) async {
    await db.insert(
      'app_flags',
      {'key': key, 'value': value ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool?> getAppFlagBool({required String key}) async {
    final rows = await db.query('app_flags', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    final v = rows.first['value'] as String?;
    if (v == null) return null;
    return v == '1' || v.toLowerCase() == 'true';
  }

  Future<int> updateLastMenstrualDay({required int userId, required String lastMenstrualDayIso}) async {
    return await db.update('users', {'last_menstrual_day': lastMenstrualDayIso}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> _dedupeModelPredictions() async {
    try {
      // Keep newest (max id) per (user, model, window) and delete others
      await db.rawDelete('''
        DELETE FROM model_predictions
        WHERE id NOT IN (
          SELECT MAX(id) FROM model_predictions
          GROUP BY user_id, model_name, window_start, window_end
        )
      ''');
    } catch (_) {
      // Ignore if the SQLite build does not support the query semantics
    }
  }

  Future<void> _createV1(Database d) async {
    await d.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_code TEXT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        dob TEXT,
        last_menstrual_day TEXT,
        created_at INTEGER
      );
    ''');

    await d.execute('''
      CREATE TABLE model_inference_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        model_name TEXT,
        input_summary TEXT,
        output_json TEXT,
        created_at INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    ''');

    await d.execute('CREATE INDEX idx_logs_user_id_created ON model_inference_logs(user_id, created_at DESC);');

    // typed symptoms table (also created on init for existing DBs)
    await d.execute('''
      CREATE TABLE IF NOT EXISTS symptoms_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        sleep_hours TEXT,
        weight_change TEXT,
        smoking_alcohol INTEGER,
        birth_control_use INTEGER,
        hair_loss INTEGER,
        acne INTEGER,
        fatigue INTEGER,
        bloating INTEGER,
        nausea INTEGER,
        dizziness INTEGER,
        hot_flashes INTEGER,
        irritability INTEGER,
        forgetfulness INTEGER,
        depression INTEGER,
        tension INTEGER,
        social_withdrawal INTEGER,
        headache INTEGER,
        lower_back_pain INTEGER,
        pain_during_sex INTEGER,
        flow INTEGER,
        pelvic_pain INTEGER,
        stress INTEGER,
        created_at INTEGER,
        UNIQUE(user_id, log_date),
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    ''');
  }

  // Password hashing
  String _randomSalt([int length = 16]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> createUser({
    required String userCode,
    required String email,
    required String password,
    required String dobIso,
    required String lastMenstrualDayIso,
  }) async {
    final salt = _randomSalt();
    final hash = _hashPassword(password, salt);
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('users', {
      'user_code': userCode,
      'email': email,
      'password_hash': hash,
      'salt': salt,
      'dob': dobIso,
      'last_menstrual_day': lastMenstrualDayIso,
      'created_at': now,
    });
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<bool> validateLogin({required String email, required String password}) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;
    final salt = user['salt'] as String;
    final expected = user['password_hash'] as String;
    final actual = _hashPassword(password, salt);
    // constant-time compare
    if (expected.length != actual.length) return false;
    int diff = 0;
    for (int i = 0; i < expected.length; i++) {
      diff |= expected.codeUnitAt(i) ^ actual.codeUnitAt(i);
    }
    return diff == 0;
  }

  Future<void> logInference({
    required int userId,
    required String modelName,
    String? inputSummary,
    required Map<String, dynamic> output,
  }) async {
    await db.insert('model_inference_logs', {
      'user_id': userId,
      'model_name': modelName,
      'input_summary': inputSummary ?? '',
      'output_json': jsonEncode(output),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> insertSymptomsLog({
    required int userId,
    required String logDateIso, // YYYY-MM-DD
    String? sleepHours,
    String? weightChange,
    required Map<String, bool> toggles,
    required Map<String, int> intensity,
  }) async {
    int b(bool? v) => (v ?? false) ? 1 : 0;
    int r(String k) => intensity[k] ?? 0; // 0..5

    await db.insert(
      'symptoms_logs',
      {
        'user_id': userId,
        'log_date': logDateIso,
        'sleep_hours': sleepHours ?? '',
        'weight_change': weightChange ?? '',
        'smoking_alcohol': b(toggles['Smoking / Alcohol']),
        'birth_control_use': b(toggles['Birth control use']),
        'hair_loss': b(toggles['Hair Loss']),
        'acne': b(toggles['Acne']),
        'fatigue': b(toggles['Fatigue']),
        'bloating': b(toggles['Bloating']),
        'nausea': b(toggles['Nausea']),
        'dizziness': b(toggles['Dizziness']),
        'hot_flashes': b(toggles['Hot flashes']),
        'irritability': b(toggles['Irritability']),
        'forgetfulness': b(toggles['Forgetfulness']),
        'depression': b(toggles['Depression']),
        'tension': b(toggles['Tension']),
        'social_withdrawal': b(toggles['Social withdrawal']),
        'headache': r('Headache'),
        'lower_back_pain': r('Lower back pain'),
        'pain_during_sex': r('Pain during sex'),
        'flow': r('Flow'),
        'pelvic_pain': r('Pelvic pain'),
        'stress': r('Stress'),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSymptomsLogByDate({
    required int userId,
    required String logDateIso,
  }) async {
    final rows = await db.query(
      'symptoms_logs',
      where: 'user_id = ? AND log_date = ?',
      whereArgs: [userId, logDateIso],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> getSymptomsLogs({
    required int userId,
    int limit = 30,
    int offset = 0,
  }) async {
    return await db.query(
      'symptoms_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'log_date DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> deleteSymptomsLogsByDates({
    required int userId,
    required List<String> datesIso,
  }) async {
    if (datesIso.isEmpty) return 0;
    final placeholders = List.filled(datesIso.length, '?').join(',');
    return await db.delete(
      'symptoms_logs',
      where: 'user_id = ? AND log_date IN ($placeholders)',
      whereArgs: [userId, ...datesIso],
    );
  }

  Future<void> saveModelPrediction({
    required int userId,
    required String modelName,
    required String windowStartIso,
    required String windowEndIso,
    required Map<String, dynamic> output,
  }) async {
    await db.insert(
      'model_predictions',
      {
        'user_id': userId,
        'model_name': modelName,
        'window_start': windowStartIso,
        'window_end': windowEndIso,
        'output_json': jsonEncode(output),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> cleanupDuplicatePredictions({required int userId}) async {
    // Delete duplicates for same (user, model, window) keeping the newest (max created_at)
    // Uses a subquery to identify ids to keep and deletes others.
    final deleted = await db.rawDelete('''
      DELETE FROM model_predictions
      WHERE id NOT IN (
        SELECT id FROM (
          SELECT id,
                 ROW_NUMBER() OVER (PARTITION BY user_id, model_name, window_start, window_end
                                    ORDER BY created_at DESC, id DESC) AS rn
          FROM model_predictions
          WHERE user_id = ?
        ) t
        WHERE t.rn = 1
      ) AND user_id = ?
    ''', [userId, userId]);
    return deleted;
  }

  // User helpers
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> updateUserEmail({required int userId, required String email}) async {
    return await db.update('users', {'email': email}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUserDob({required int userId, required String dobIso}) async {
    return await db.update('users', {'dob': dobIso}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUserPassword({required int userId, required String newPassword}) async {
    final salt = _randomSalt();
    final hash = _hashPassword(newPassword, salt);
    return await db.update('users', {'password_hash': hash, 'salt': salt}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> deleteUser({required int userId}) async {
    // delete dependent rows first
    await db.delete('symptoms_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('model_inference_logs', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('model_predictions', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> deletePredictionsForUser({required int userId, String? modelName}) async {
    if (modelName == null) {
      return await db.delete('model_predictions', where: 'user_id = ?', whereArgs: [userId]);
    }
    return await db.delete('model_predictions', where: 'user_id = ? AND model_name = ?', whereArgs: [userId, modelName]);
  }

  // Cycles helpers
  Future<void> upsertCycle({
    required int userId,
    required String firstDayIso,
    required int periodLength,
    required int cycleLength,
  }) async {
    await db.insert(
      'cycles',
      {
        'user_id': userId,
        'first_day': firstDayIso,
        'period_length': periodLength,
        'cycle_length': cycleLength,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentCycles({required int userId, int limit = 6}) async {
    return await db.query(
      'cycles',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'first_day DESC',
      limit: limit,
    );
  }

  Future<int> seedSampleCycles({required int userId}) async {
    // Insert 6 sample cycles ending near today using 28-29 day cycles and 4-6 day periods
    final now = DateTime.now();
    // Determine a current cycle start from users table if available
    DateTime base = now;
    try {
      final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
      if (rows.isNotEmpty) {
        final s = rows.first['last_menstrual_day'] as String?;
        if (s != null && s.isNotEmpty) {
          base = DateTime.parse(s);
        }
      }
    } catch (_) {}

    int count = 0;
    for (int i = 0; i < 6; i++) {
      final start = DateTime(base.year, base.month, base.day).subtract(Duration(days: 28 * i));
      final firstIso = start.toIso8601String().substring(0, 10);
      final periodLen = 4 + (i % 3); // 4..6
      final cycleLen = 28 + (i % 2); // 28..29
      await upsertCycle(userId: userId, firstDayIso: firstIso, periodLength: periodLen, cycleLength: cycleLen);
      count++;
    }
    return count;
  }
}
