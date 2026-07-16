class PackingItem {
  final String name; // Eşyanın adı
  final int weightInGrams; // Ağırlığı (gram)
  bool isChecked; // Seçildi mi?

  PackingItem({
    required this.name,
    required this.weightInGrams,
    this.isChecked = false,
  });
}
