import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_store_app_admin/models/product_model.dart';

class ProductController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadProductImage(Uint8List image, String imageName) async {
    try {
      var ref = _storage.ref().child('products').child(imageName);
      UploadTask uploadTask = ref.putData(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload product image: $e");
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
    } catch (e) {
      throw Exception("Failed to add product: $e");
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception("Failed to delete product: $e");
    }
  }

  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('categories').snapshots();
  }
}
