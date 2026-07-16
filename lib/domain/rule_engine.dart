import '../data/models/packing_item_model.dart';

class RuleEngine {
  static List<PackingItem> generatePackingList({
    required int days,
    required String purpose,
    required String weatherCondition,
  }) {
    List<PackingItem> list = [];

    // 1. Demirbaş Eşyalar
    list.add(PackingItem(name: "Diş Fırçası ve Macunu", weightInGrams: 100));
    list.add(PackingItem(name: "Telefon Şarj Aleti", weightInGrams: 150));
    list.add(PackingItem(name: "Kimlik / Pasaport", weightInGrams: 50));
    list.add(
      PackingItem(name: "$days adet İç Çamaşırı", weightInGrams: days * 50),
    );
    list.add(PackingItem(name: "$days adet Çorap", weightInGrams: days * 40));

    // 2. Seyahat Amacı Kuralları
    if (purpose == "İş") {
      list.add(PackingItem(name: "Takım Elbise / Ceket", weightInGrams: 1200));
      list.add(PackingItem(name: "Laptop ve Adaptör", weightInGrams: 2200));
    } else if (purpose == "Tatil") {
      list.add(PackingItem(name: "Mayo / Bikini", weightInGrams: 200));
      list.add(PackingItem(name: "Güneş Gözlüğü", weightInGrams: 100));
      list.add(PackingItem(name: "Yedek Terlik", weightInGrams: 400));
    } else if (purpose == "Kamp") {
      list.add(PackingItem(name: "Çadır (Hafif Kamp)", weightInGrams: 3500));
      list.add(PackingItem(name: "Uyku Tulumu", weightInGrams: 1500));
      list.add(PackingItem(name: "Powerbank", weightInGrams: 400));
    }

    // 3. Hava Durumu Kuralları
    String condition = weatherCondition.toLowerCase();
    if (condition.contains("rain") || condition.contains("yağmur")) {
      list.add(PackingItem(name: "Şemsiye", weightInGrams: 350));
      list.add(PackingItem(name: "Yağmurluk", weightInGrams: 500));
    } else if (condition.contains("snow") ||
        condition.contains("soğuk") ||
        condition.contains("cold")) {
      list.add(PackingItem(name: "Kalın Kaban / Mont", weightInGrams: 1800));
      list.add(PackingItem(name: "Atkı ve Bere", weightInGrams: 300));
    }

    return list;
  }
}
