class InspectionItem {
  final String id;
  final String title;
  final String description;
  final String cycle;
  bool isChecked;

  InspectionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cycle,
    this.isChecked = false,
  });

  factory InspectionItem.fromJson(Map<String, dynamic> json) {
    return InspectionItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      cycle: json['cycle'],
      isChecked: json['isChecked'] ?? false,
    );
  }
}