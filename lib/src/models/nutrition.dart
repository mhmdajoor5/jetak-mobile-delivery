class Nutrition {
  String? id;
  String? name;
  double? quantity;

  Nutrition();

  Nutrition.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'],
        quantity = jsonMap['quantity'].toDouble();

  @override
  bool operator ==(dynamic other) {
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
