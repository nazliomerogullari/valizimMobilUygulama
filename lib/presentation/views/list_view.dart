import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/packing_item_model.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/services/weather_service.dart';
import '../../../domain/rule_engine.dart';

class PackingListView extends StatefulWidget {
  final String city;
  final int days;
  final String purpose;

  const PackingListView({
    super.key,
    required this.city,
    required this.days,
    required this.purpose,
  });

  @override
  State<PackingListView> createState() => _PackingListViewState();
}

class _PackingListViewState extends State<PackingListView> {
  List<PackingItem> _packingItems = [];
  final double _maxBaggaeLimitKg = 20.0;

  final WeatherService _weatherService = WeatherService();
  final Box _valizBox = Hive.box('valiz_kutusu');

  bool _isLoading = true;
  String _weatherConditionText = "Yükleniyor...";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Önce yerelde bu şehre ait bir kayıt var mı kontrol et
    List<dynamic>? cachedItems = _valizBox.get('${widget.city}_list');
    List<dynamic>? cachedStatus = _valizBox.get('${widget.city}_status');

    if (cachedItems != null && cachedStatus != null) {
      _packingItems = [];
      for (int i = 0; i < cachedItems.length; i++) {
        _packingItems.add(
          PackingItem(
            name: cachedItems[i],
            weightInGrams: _valizBox.get('${widget.city}_weight_$i') ?? 100,
            isChecked: cachedStatus[i],
          ),
        );
      }
      _weatherConditionText =
          _valizBox.get('${widget.city}_weather') ?? "Kayıttan Yüklendi";

      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 2. Yerelde veri yoksa API'ye git
    try {
      WeatherModel weather = await _weatherService.fetchWeather(widget.city);
      _weatherConditionText =
          "${weather.temperature.toStringAsFixed(0)}°C, ${weather.condition}";

      _packingItems = RuleEngine.generatePackingList(
        days: widget.days,
        purpose: widget.purpose,
        weatherCondition: weather.condition,
      );

      // İlk kez çekilen listeyi hemen yerele kaydet
      _saveToLocal();
    } catch (e) {
      _weatherConditionText = "Hava durumu alınamadı";
      _packingItems = RuleEngine.generatePackingList(
        days: widget.days,
        purpose: widget.purpose,
        weatherCondition: "sunny",
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveToLocal() {
    List<String> names = _packingItems.map((e) => e.name).toList();
    List<bool> status = _packingItems.map((e) => e.isChecked).toList();

    _valizBox.put('${widget.city}_list', names);
    _valizBox.put('${widget.city}_status', status);
    _valizBox.put('${widget.city}_weather', _weatherConditionText);

    for (int i = 0; i < _packingItems.length; i++) {
      _valizBox.put('${widget.city}_weight_$i', _packingItems[i].weightInGrams);
    }
  }

  double get _currentTotalWeightKg {
    int totalGrams = 0;
    for (var item in _packingItems) {
      if (item.isChecked) {
        totalGrams += item.weightInGrams;
      }
    }
    return totalGrams / 1000;
  }

  @override
  Widget build(BuildContext context) {
    double progressRatio = _currentTotalWeightKg / _maxBaggaeLimitKg;
    if (progressRatio > 1.0) progressRatio = 1.0;

    Color barColor = _currentTotalWeightKg > _maxBaggaeLimitKg
        ? Colors.red
        : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.city} Valizi'),
        backgroundColor: barColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 📊 CANLI AĞIRLIK GÖSTERGE KARTI
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: barColor.withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mevcut Ağırlık: ${_currentTotalWeightKg.toStringAsFixed(2)} kg",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: barColor,
                            ),
                          ),
                          Text(
                            "Hava: $_weatherConditionText",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Colors.grey[300],
                        color: barColor,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      if (_currentTotalWeightKg > _maxBaggaeLimitKg)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "⚠️ Dikkat! Havayolu bagaj sınırını aştınız!",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // EŞYA LİSTESİ
                Expanded(
                  child: ListView.builder(
                    itemCount: _packingItems.length,
                    itemBuilder: (context, index) {
                      final item = _packingItems[index];

                      return CheckboxListTile(
                        title: Text(item.name),
                        subtitle: Text("${item.weightInGrams} gram"),
                        value: item.isChecked,
                        activeColor: barColor,
                        onChanged: (bool? value) {
                          setState(() {
                            item.isChecked = value!;
                          });
                          _saveToLocal(); // Her değişiklikte durumu telefona kaydet
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
