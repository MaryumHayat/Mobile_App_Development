class CartItem {
  final String image;
  final String description;
  final int basePrice;
  String size;
  int quantity;
  int sizeSurcharge;

  CartItem({
    required this.image,
    required this.description,
    required this.basePrice,
    this.size = "Small",
    this.quantity = 1,
    this.sizeSurcharge = 0,
  });

  int get total => (basePrice + sizeSurcharge) * quantity;
}

List<CartItem> globalCart = [];