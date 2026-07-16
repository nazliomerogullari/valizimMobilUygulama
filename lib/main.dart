import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/views/home_view.dart';

void main() async {
  // Flutter asenkron işlemlerini garantiye alıyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Yerel veritabanı Hive'ı başlatıyoruz
  await Hive.initFlutter();

  // "valiz_kutusu" adında yerel veri odamızı açıyoruz
  await Hive.openBox('valiz_kutusu');

  runApp(const ValizimApp());
}

class ValizimApp extends StatelessWidget {
  const ValizimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valizim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
