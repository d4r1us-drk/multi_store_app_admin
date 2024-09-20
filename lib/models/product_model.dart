class ProductModel {
  final String id;
  final String productName;
  final double price;
  final double discount;
  final int quantity;
  final String description;
  final String category;
  final String size;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.discount,
    required this.quantity,
    required this.description,
    required this.category,
    required this.size,
    required this.images,
  });

  factory ProductModel.fromDocument(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      productName: data['productName'],
      price: data['price'],
      discount: data['discount'],
      quantity: data['quantity'],
      description: data['description'],
      category: data['category'],
      size: data['size'],
      images: List<String>.from(data['images']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'description': description,
      'category': category,
      'size': size,
      'images': images,
    };
  }
}
