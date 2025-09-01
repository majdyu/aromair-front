class OptionItem {
  final int id;
  final String label;
  OptionItem({required this.id, required this.label});

  factory OptionItem.fromJson(Map<String, dynamic> j)
    => OptionItem(id: (j['id'] as num).toInt(), label: j['label'] ?? '');
}
