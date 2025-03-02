import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ใช้ alias เพื่อป้องกันชื่อซ้ำ
import 'formScreen.dart' as form;
import 'edit_screen.dart' as edit;

import 'package:account/provider/performance_provider.dart';
import 'package:account/model/performanceItem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PerformanceProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Theater Performances',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.black,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.amber, fontSize: 22),
          ),
        ),
        home: const MyHomePage(title: 'การแสดงละครเวที'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PerformanceProvider>(context, listen: false).initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.amber),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return form.FormScreen();
              }));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<PerformanceProvider>(
          builder: (context, provider, child) {
            int itemCount = provider.performances.length;
            if (itemCount == 0) {
              return const Center(
                child: Text(
                  'ไม่มีการแสดง',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              );
            } else {
              return GridView.builder(
                padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 12, right: 12, bottom: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // ปรับให้การ์ดมีขนาดที่เหมาะสม
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7, // ✅ ทำให้การ์ดมีขนาดพอดี
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  PerformanceItem data = provider.performances[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return edit.EditScreen(item: data);
                          },
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned.fill(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      data.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'วันที่: ${data.date?.toIso8601String().split('T')[0]}',
                                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('ยืนยันการลบ'),
                                          content: const Text('คุณต้องการลบการแสดงนี้ใช่หรือไม่?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('ยกเลิก'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
                                              onPressed: () {
                                                if (data.keyID != null) {
                                                  provider.deletePerformance(data.keyID!);
                                                } else {
                                                  debugPrint("❌ keyID เป็น null");
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}