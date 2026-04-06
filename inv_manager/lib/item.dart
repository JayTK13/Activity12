class Item {
  final String id;
  final String name;
  final int quantity;

  Item({required this.id, required this.name, required this.quantity});

  Map<String, dynamic> toMap() {
    return {'name': name, 'quantity': quantity};
  }

  factory Item.fromMap(String id, Map<String, dynamic> data) {
    return Item(
      id: id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
    );
  }
}
