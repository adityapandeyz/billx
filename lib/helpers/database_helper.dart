import 'dart:io' as io;

import 'package:billx/models/split_bill.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/category.dart';
import '../models/fabric.dart';
import '../models/item.dart';
import '../models/offline_bill.dart';
import '../models/online_bill.dart';

class DatabaseHelper {
  // returns the instance of DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // reference to the database marked as private
  static Database? _database;

  // factory method that returns an instance of DatabaseHelper
  // to ensure that DatabaseHelper has only one instance in the application
  DatabaseHelper._privateConstructor();

  // get the database, if it is not initialized, initialize it first
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    // initialize the ffi loader to ensure that sqlite will work
    sqfliteFfiInit();

    // create path to store the database
    final io.Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbPath =
        p.join(appDirectory.path, 'databases', 'billx_database1.db');

    final dbFactory = databaseFactoryFfi;

    // Open the database and return the reference
    return await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  // Future<void> _onCreate(Database db, int version) async {
  //   // create 'firms' table
  //   await db.execute('''
  //   CREATE TABLE IF NOT EXISTS firms (
  //     id INTEGER PRIMARY KEY,
  //     name TEXT NOT NULL,
  //     firmId  TEXT NOT NULL UNIQUE,
  //     address TEXT NOT NULL,
  //     gstin TEXT NOT NULL,
  //     phone TEXT NOT NULL,
  //     password TEXT NOT NULL
  //   )
  // ''');
  // }

  Future<void> _onCreate(Database db, int version) async {
    // Create 'category' table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS category (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    categoryId TEXT NOT NULL,
    firmId TEXT NOT NULL
  );
''');

// Create 'firms' table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS firms (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    firmId TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL,
    gstin TEXT NOT NULL,
    phone TEXT NOT NULL,
    password TEXT NOT NULL
  );
''');

// Create 'items' table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    itemId TEXT NOT NULL,
    size TEXT NOT NULL,
    barcode TEXT NOT NULL,
    price INTEGER NOT NULL,
    category TEXT NOT NULL,
    firmId TEXT NOT NULL
  );
''');

// // Create 'fabric' table
//     await db.execute('''
//   CREATE TABLE IF NOT EXISTS fabric (
//     id INTEGER PRIMARY KEY,
//     name TEXT NOT NULL,
//     fabricId TEXT NOT NULL,
//     totalStock REAL NOT NULL,
//     totalStockSold REAL NOT NULL,
//     pricePerUnit REAL NOT NULL,
//     manufacturer TEXT NOT NULL,
//     fabricType TEXT NOT NULL,
//     firmId TEXT NOT NULL
//   );
// ''');

// Create 'offline_bill' table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS offline_bill (
    id INTEGER PRIMARY KEY,
    firmId TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    invoice TEXT NOT NULL,
    items TEXT NOT NULL,  -- Use TEXT for JSON
    netAmount REAL NOT NULL,
    totalTax REAL NOT NULL,
    modeOfPayment TEXT NOT NULL,
    totalQuantity INTEGER NOT NULL,
    discAmount REAL NOT NULL,
  );
''');

// Create 'online_bill' table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS online_bill (
    id INTEGER PRIMARY KEY,
    firmId TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    invoice TEXT NOT NULL,
    items TEXT NOT NULL,  -- Use TEXT for JSON
    netAmount REAL NOT NULL,
    totalTax REAL NOT NULL,
    modeOfPayment TEXT NOT NULL,
    totalQuantity INTEGER NOT NULL,
    discAmount REAL NOT NULL,
  );
''');

// Create 'split_bill' table
    await db.execute('''
  CREATE TABLE IF NOT EXISTS split_bill (
    id INTEGER PRIMARY KEY,
    firmId TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    invoice TEXT NOT NULL,
    items TEXT NOT NULL,  -- Use TEXT for JSON
    cashAmount REAL NOT NULL,
    onlineAmount REAL NOT NULL,
    netAmount REAL NOT NULL,
    totalTax REAL NOT NULL,
    onlinePaymentMode TEXT NOT NULL,
    totalQuantity INTEGER NOT NULL,
    discAmount REAL NOT NULL,
  );
''');
  }

  //firm
  Future<int> createFirm({
    required String firmName,
    required String firmId,
    required String gstin,
    required String phone,
    required String address,
    required String password,
  }) async {
    final Database db = await database;

    int result = await db.insert(
      'firms',
      <String, Object?>{
        'name': firmName,
        'firmId': firmId.toUpperCase(),
        'gstin': gstin.toUpperCase(),
        'phone': phone,
        'address': address,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllFirms() async {
    final Database db = await database;
    return await db.query('firms');
  }

  //category
  Future<int> createCategory(Category category) async {
    final db = await database;
    return await db.insert('category', category.toJson());
  }

  Future<List<Category>> getCategories(String currentFirmId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'category',
      where: 'firmId = ?',
      whereArgs: [currentFirmId],
    );
    return List.generate(maps.length, (index) {
      return Category.fromJson(maps[index]);
    });
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      'category',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(Category category) async {
    final db = await database;
    await db.delete(
      'category',
      where: 'id = ?',
      whereArgs: [category.categoryId],
    );
  }

  // items
  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('items', item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<List<Item>> getAllItems(String currentFirmId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'firmId = ?',
      whereArgs: [currentFirmId],
    );

    return List.generate(maps.length, (i) {
      return Item.fromJson(maps[i]);
    });
  }

  Future<void> deleteItem(Item item) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [item.id]);
  }

  // offline bills
  Future<List<OfflineBill>> getOfflineBills(String currentFirmId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'offline_bill',
      where: 'firmId = ?',
      whereArgs: [currentFirmId],
    );
    return List.generate(maps.length, (i) {
      return OfflineBill.fromJson(maps[i]);
    });
  }

  Future<void> insertOfflineBill(OfflineBill offlineBill) async {
    final db = await database;
    await db.insert('offline_bill', offlineBill.toJson());
  }

  Future<void> updateOfflineBill(OfflineBill offlineBill) async {
    final db = await database;
    await db.update(
      'offline_bill',
      offlineBill.toJson(),
      where: 'id = ?',
      whereArgs: [offlineBill.id],
    );
  }

  Future<void> deleteOfflineBill(int billId) async {
    final db = await database;
    await db.delete('offline_bill', where: 'id = ?', whereArgs: [billId]);
  }

  // online bill
  Future<List<OnlineBill>> getOnlineBills(String currentFirmId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'online_bill',
      where: 'firmId = ?',
      whereArgs: [currentFirmId],
    );
    return List.generate(maps.length, (i) {
      return OnlineBill.fromJson(maps[i]);
    });
  }

  Future<void> insertOnlineBill(OnlineBill onlineBill) async {
    final db = await database;
    await db.insert('online_bill', onlineBill.toJson());
  }

  Future<void> updateOnlineBill(OnlineBill onlineBill) async {
    final db = await database;
    await db.update(
      'online_bill',
      onlineBill.toJson(),
      where: 'id = ?',
      whereArgs: [onlineBill.id],
    );
  }

  Future<void> deleteOnlineBill(int id) async {
    final db = await database;
    await db.delete('online_bill', where: 'id = ?', whereArgs: [id]);
  }

  // split bill
  Future<List<SplitBill>> getSplitBills(String currentFirmId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'split_bill',
      where: 'firmId = ?',
      whereArgs: [currentFirmId],
    );
    return List.generate(maps.length, (i) {
      return SplitBill.fromJson(maps[i]);
    });
  }

  Future<void> insertSplitBill(SplitBill splitBill) async {
    final db = await database;
    await db.insert('split_bill', splitBill.toJson());
  }

  Future<void> updateSplitBill(SplitBill splitBill) async {
    final db = await database;
    await db.update(
      'split_bill',
      splitBill.toJson(),
      where: 'id = ?',
      whereArgs: [splitBill.id],
    );
  }

  Future<void> deleteSplitBill(int id) async {
    final db = await database;
    await db.delete('split_bill', where: 'id = ?', whereArgs: [id]);
  }

  // Future<void> insertFabric(Fabric fabric) async {
  //   final db = await database;
  //   await db.insert('fabric', fabric.toJson(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }

  // Future<List<Fabric>> getAllFabrics(String currentFirmId) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'fabric',
  //     where: 'firmId = ?',
  //     whereArgs: [currentFirmId],
  //   );

  //   return List.generate(maps.length, (i) {
  //     return Fabric.fromJson(maps[i]);
  //   });
  // }

  // Future<void> updateFabric(Fabric fabric) async {
  //   final db = await database;
  //   await db.update(
  //     'fabric',
  //     fabric.toJson(),
  //     where: 'id = ?',
  //     whereArgs: [fabric.id],
  //   );
  // }

  // Future<void> deleteFabric(int fabricId) async {
  //   final db = await database;
  //   await db.delete('fabric', where: 'id = ?', whereArgs: [fabricId]);
  // }
}
