import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart'; // ✅ ใช้เปรียบเทียบ List
import 'package:account/model/performanceItem.dart';
import 'package:account/database/performance_db.dart';

class PerformanceProvider with ChangeNotifier {
  final PerformanceDB _db = PerformanceDB(dbName: 'performances.db');
  List<PerformanceItem> _performances = [];

  List<PerformanceItem> get performances => List.unmodifiable(_performances);

  /// ✅ โหลดข้อมูลจากฐานข้อมูล
  Future<void> initData() async {
    try {
      await refreshData();
    } catch (e, stacktrace) {
      debugPrint("❌ initData() ล้มเหลว: $e\n$stacktrace");
    }
  }

  /// ✅ เพิ่มการแสดงใหม่
  Future<void> addPerformance(PerformanceItem performance) async {
    try {
      int newID = await _db.insertDatabase(performance);
      if (newID > 0) {
        _performances.add(performance.copyWith(keyID: newID));
        notifyListeners();
        debugPrint("✅ เพิ่มข้อมูลสำเร็จ: ${performance.title}");
      } else {
        debugPrint("⚠️ ไม่สามารถเพิ่มข้อมูลได้: ${performance.title}");
      }
    } catch (e, stacktrace) {
      debugPrint("❌ เพิ่มข้อมูลล้มเหลว: $e\n$stacktrace");
    }
  }

  /// ✅ ลบการแสดงโดยใช้ keyID
  Future<void> deletePerformance(int? keyID) async {
    if (keyID == null) {
      debugPrint("❌ keyID เป็น null ลบไม่ได้");
      return;
    }
    try {
      await _db.deleteData(keyID); // ✅ แก้ให้ไม่รับค่าคืนจากฟังก์ชัน
      _performances.removeWhere((item) => item.keyID == keyID);
      notifyListeners();
      debugPrint("✅ ลบข้อมูลสำเร็จ: keyID = $keyID");
    } catch (e, stacktrace) {
      debugPrint("❌ ลบข้อมูลล้มเหลว: $e\n$stacktrace");
    }
  }

  /// ✅ อัปเดตการแสดง
  Future<void> updatePerformance(PerformanceItem performance) async {
    if (performance.keyID == null) {
      debugPrint("❌ keyID เป็น null อัปเดตไม่ได้");
      return;
    }
    try {
      await _db.updateData(performance); // ✅ แก้ให้ไม่รับค่าคืนจากฟังก์ชัน
      int index = _performances.indexWhere((item) => item.keyID == performance.keyID);
      if (index != -1) {
        _performances[index] = performance;
        notifyListeners();
        debugPrint("✅ อัปเดตข้อมูลสำเร็จ: ${performance.title}");
      }
    } catch (e, stacktrace) {
      debugPrint("❌ อัปเดตข้อมูลล้มเหลว: $e\n$stacktrace");
    }
  }

  /// ✅ โหลดข้อมูลใหม่ทั้งหมดจากฐานข้อมูล
  Future<void> refreshData() async {
    try {
      List<PerformanceItem> newData = await _db.loadAllData();

      // เปรียบเทียบข้อมูลก่อนแจ้งเตือน UI
      if (!const DeepCollectionEquality().equals(_performances, newData)) {
        _performances = newData;
        notifyListeners();
        debugPrint("🔄 โหลดข้อมูลใหม่ ${newData.length} รายการ");
      } else {
        debugPrint("✅ ข้อมูลยังเหมือนเดิม ไม่ต้องอัปเดต UI");
      }
    } catch (e, stacktrace) {
      debugPrint("❌ โหลดข้อมูลล้มเหลว: $e\n$stacktrace");
    }
  }
}