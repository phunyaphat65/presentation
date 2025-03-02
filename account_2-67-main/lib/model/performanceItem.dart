class PerformanceItem { 
  int? keyID;
  String title; // ชื่อการแสดง
  DateTime? date; // วันที่จัดการแสดง
  String location; // สถานที่จัดการแสดง
  String description; // รายละเอียดของการแสดง
  double ticketPrice; // ราคาตั๋ว
  String? imagePath; // ✅ เปลี่ยนจาก imageUrl เป็น imagePath สำหรับไฟล์โลคอล

  PerformanceItem({
    this.keyID,
    required this.title,
    this.date,
    required this.location,
    required this.description,
    required this.ticketPrice,
    this.imagePath, // ✅ เปลี่ยนชื่อฟิลด์
  });

  /// ✅ Getter สำหรับ id
  int? get id => keyID;

  /// ✅ แปลงเป็น JSON สำหรับบันทึกข้อมูล
  Map<String, dynamic> toJson() {
    return {
      'keyID': keyID,
      'title': title,
      'date': date?.toIso8601String(),
      'location': location,
      'description': description,
      'ticketPrice': ticketPrice,
      'imagePath': imagePath, // ✅ ใช้ imagePath แทน imageUrl
    };
  }

  /// ✅ โหลดจาก JSON
  factory PerformanceItem.fromJson(Map<String, dynamic> json) {
    return PerformanceItem(
      keyID: json['keyID'],
      title: json['title'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      location: json['location'],
      description: json['description'],
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      imagePath: json['imagePath'], // ✅ ใช้ imagePath แทน imageUrl
    );
  }

  /// ✅ สร้างอ็อบเจ็กต์ใหม่โดยเปลี่ยนเฉพาะบางค่า
  PerformanceItem copyWith({
    int? keyID,
    String? title,
    DateTime? date,
    String? location,
    String? description,
    double? ticketPrice,
    String? imagePath, // ✅ เปลี่ยนจาก imageUrl เป็น imagePath
  }) {
    return PerformanceItem(
      keyID: keyID ?? this.keyID,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      imagePath: imagePath ?? this.imagePath, // ✅ ใช้ imagePath
    );
  }
}