import 'dart:io'; 
import 'package:account/model/performanceItem.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';


class PerformanceDB {
  final String dbName;

  PerformanceDB({required this.dbName});

  /// ✅ เปิดฐานข้อมูล (ป้องกันข้อผิดพลาด)
  Future<Database> openDatabase() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbLocation = join(appDir.path, dbName);
      DatabaseFactory dbFactory = databaseFactoryIo;
      return await dbFactory.openDatabase(dbLocation);
    } catch (e) {
      throw Exception("เปิดฐานข้อมูลล้มเหลว: $e");
    }
  }

  /// ✅ เพิ่มข้อมูล (ป้องกัน null และข้อผิดพลาด)
  Future<int> insertDatabase(PerformanceItem item) async {
    Database? db;
    try {
      db = await openDatabase();
      var store = intMapStoreFactory.store('performance');

      int keyID = await store.add(db, {
        'title': item.title,
        'date': item.date?.toIso8601String(),
        'location': item.location,
        'description': item.description,
        'ticketPrice': item.ticketPrice,
        'imagePath': item.imagePath ?? ''
      });

      return keyID;
    } catch (e) {
      throw Exception("เพิ่มข้อมูลล้มเหลว: $e");
    } finally {
      await db?.close();
    }
  }

  /// ✅ โหลดข้อมูลทั้งหมด (ป้องกัน null และข้อมูลผิดประเภท)
  Future<List<PerformanceItem>> loadAllData() async {
    Database? db;
    try {
      db = await openDatabase();
      var store = intMapStoreFactory.store('performance');

      var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder('date', false)]));

      return snapshot.map((record) {
        return PerformanceItem(
          keyID: record.key,
          title: record['title']?.toString() ?? 'ไม่มีชื่อ',
          date: record['date'] != null ? DateTime.tryParse(record['date'].toString()) : null,
          location: record['location']?.toString() ?? 'ไม่มีสถานที่',
          description: record['description']?.toString() ?? 'ไม่มีรายละเอียด',
          ticketPrice: num.tryParse(record['ticketPrice'].toString())?.toDouble() ?? 0.0,
          imagePath: record['imagePath']?.toString() ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception("โหลดข้อมูลล้มเหลว: $e");
    } finally {
      await db?.close();
    }
  }

  /// ✅ ลบข้อมูลโดยใช้ keyID (ป้องกันข้อผิดพลาด)
  Future<void> deleteData(int keyID) async {
    Database? db;
    try {
      db = await openDatabase();
      var store = intMapStoreFactory.store('performance');

      await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, keyID)));
    } catch (e) {
      throw Exception("ลบข้อมูลล้มเหลว: $e");
    } finally {
      await db?.close();
    }
  }

  /// ✅ อัปเดตข้อมูล (ป้องกัน null และข้อผิดพลาด)
  Future<void> updateData(PerformanceItem item) async {
    Database? db;
    try {
      db = await openDatabase();
      var store = intMapStoreFactory.store('performance');

      await store.update(
        db,
        {
          'title': item.title,
          'date': item.date?.toIso8601String(),
          'location': item.location,
          'description': item.description,
          'ticketPrice': item.ticketPrice,
          'imagePath': item.imagePath ?? ''
        },
        finder: Finder(filter: Filter.equals(Field.key, item.keyID)),
      );
    } catch (e) {
      throw Exception("อัปเดตข้อมูลล้มเหลว: $e");
    } finally {
      await db?.close();
    }
  }
}