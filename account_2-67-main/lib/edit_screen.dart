import 'package:account/model/performanceItem.dart';
import 'package:account/provider/performance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditScreen extends StatefulWidget {
  PerformanceItem item;

  EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final ticketPriceController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title;
    locationController.text = widget.item.location;
    descriptionController.text = widget.item.description;
    ticketPriceController.text = widget.item.ticketPrice.toString();
    selectedDate = widget.item.date;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลการแสดง'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.amber, fontSize: 22),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 16, right: 16),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ชื่อการแสดง', filled: true, fillColor: Colors.white10),
                  style: const TextStyle(color: Colors.white),
                  controller: titleController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "กรุณาป้อนชื่อการแสดง";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'สถานที่จัดการแสดง', filled: true, fillColor: Colors.white10),
                  style: const TextStyle(color: Colors.white),
                  controller: locationController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "กรุณาป้อนสถานที่จัดการแสดง";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'รายละเอียดการแสดง', filled: true, fillColor: Colors.white10),
                  style: const TextStyle(color: Colors.white),
                  controller: descriptionController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "กรุณาป้อนรายละเอียดการแสดง";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ราคาตั๋ว', filled: true, fillColor: Colors.white10),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  controller: ticketPriceController,
                  validator: (String? value) {
                    try {
                      double ticketPrice = double.parse(value!);
                      if (ticketPrice <= 0) {
                        return "กรุณาป้อนราคาตั๋วที่มากกว่า 0";
                      }
                    } catch (e) {
                      return "กรุณาป้อนราคาตั๋วเป็นตัวเลขเท่านั้น";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    "วันที่แสดง: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : "ยังไม่ได้เลือก"}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.amber),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      var provider = Provider.of<PerformanceProvider>(context, listen: false);
                      PerformanceItem item = PerformanceItem(
                        keyID: widget.item.keyID,
                        title: titleController.text,
                        location: locationController.text,
                        description: descriptionController.text,
                        ticketPrice: double.parse(ticketPriceController.text),
                        date: selectedDate,
                      );
                      provider.updatePerformance(item);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('บันทึกการแก้ไข', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}