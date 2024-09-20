class CategoryModel {
  final String id;
  final String categoryName;
  final String categoryImage;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.categoryImage,
  });

  // Factory method to create a CategoryModel from Firestore document
  factory CategoryModel.fromDocument(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      categoryName: data['categoryName'],
      categoryImage: data['categoryImage'],
    );
  }

  // Convert a CategoryModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'categoryImage': categoryImage,
    };
  }
}
