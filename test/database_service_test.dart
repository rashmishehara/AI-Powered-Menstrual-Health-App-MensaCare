import 'package:flutter_test/flutter_test.dart';
import 'package:mensacare/services/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {

  group('DatabaseService', () {
    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await DatabaseService.instance.init(dbPath: inMemoryDatabasePath);
    });

// Test 1: User Creation, Retrieval & Login Validation
    test('createUser and getUserByEmail / validateLogin', () async {
      final id = await DatabaseService.instance.createUser(
        userCode: 'MC000100',
        email: 'testuser@example.com',
        password: 'secret123',
        dobIso: '1990-01-01',
        lastMenstrualDayIso: '2025-11-01',
      );
      expect(id, isNonZero);

      final user = await DatabaseService.instance.getUserByEmail('testuser@example.com');
      expect(user, isNotNull);
      expect(user!['email'], 'testuser@example.com');

      final valid = await DatabaseService.instance.validateLogin(email: 'testuser@example.com', password: 'secret123');
      expect(valid, isTrue);

      final invalid = await DatabaseService.instance.validateLogin(email: 'testuser@example.com', password: 'wrong');
      expect(invalid, isFalse);
    });

// Test 2: Insert Symptoms Log & Retrieve by Date
    test('insertSymptomsLog and getSymptomsLogByDate', () async {
      final uid = await DatabaseService.instance.createUser(
        userCode: 'MC000101',
        email: 'symuser@example.com',
        password: 'pwd',
        dobIso: '1995-05-05',
        lastMenstrualDayIso: '2025-11-05',
      );
      expect(uid, isNonZero);

      await DatabaseService.instance.insertSymptomsLog(
        userId: uid,
        logDateIso: '2025-11-19',
        sleepHours: '7',
        weightChange: 'Normal',
        toggles: {'Smoking / Alcohol': false, 'Birth control use': false, 'Hair Loss': false, 'Acne': false, 'Fatigue': false, 'Bloating': false, 'Nausea': false, 'Dizziness': false, 'Hot flashes': false, 'Irritability': false, 'Forgetfulness': false, 'Depression': false, 'Tension': false, 'Social withdrawal': false},
        intensity: {'Headache': 2, 'Lower back pain': 0, 'Pain during sex': 0, 'Flow': 1, 'Pelvic pain': 0, 'Stress': 0},
      );

      final row = await DatabaseService.instance.getSymptomsLogByDate(userId: uid, logDateIso: '2025-11-19');
      expect(row, isNotNull);
      expect(row!['log_date'], '2025-11-19');
      expect(row['sleep_hours'], '7');
    });

// Test 3: Save Model Prediction & Query Table
    test('saveModelPrediction and query table', () async {
      final uid = await DatabaseService.instance.createUser(
        userCode: 'MC000102',
        email: 'preduser@example.com',
        password: 'pwd2',
        dobIso: '1992-02-02',
        lastMenstrualDayIso: '2025-11-10',
      );
      expect(uid, isNonZero);

      await DatabaseService.instance.saveModelPrediction(
        userId: uid,
        modelName: 'test_model_v1',
        windowStartIso: '2025-11-10',
        windowEndIso: '2025-11-14',
        output: {'bloating': 0.8, 'acne': 0.1},
      );

      final rows = await DatabaseService.instance.db.query('model_predictions', where: 'user_id = ?', whereArgs: [uid]);
      expect(rows.length, greaterThanOrEqualTo(1));
      expect(rows.first['model_name'], 'test_model_v1');
    });
  });
}
