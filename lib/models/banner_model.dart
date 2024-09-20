class BannerModel {
  final String id;
  final String bannerImage;
  int viewOrder;

  BannerModel({
    required this.id,
    required this.bannerImage,
    required this.viewOrder,
  });

  // Factory method to create a BannerModel from Firestore document
  factory BannerModel.fromDocument(Map<String, dynamic> data, String id) {
    return BannerModel(
      id: id,
      bannerImage: data['bannerImage'],
      viewOrder: data['viewOrder'],
    );
  }

  // Convert a BannerModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bannerImage': bannerImage,
      'viewOrder': viewOrder,
    };
  }
}
