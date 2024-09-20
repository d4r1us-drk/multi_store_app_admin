import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_store_app_admin/models/category_model.dart';

class CategoryController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadCategoryImage(Uint8List image, String fileName) async {
    try {
      var ref = _storage.ref().child('categories').child(fileName);
      UploadTask uploadTask = ref.putData(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload category image: $e");
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').add(category.toMap());
    } catch (e) {
      throw Exception("Failed to add category: $e");
    }
  }

  Future<void> updateCategory(String categoryId, String newName) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'categoryName': newName,
      });
    } catch (e) {
      throw Exception("Failed to update category: $e");
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception("Failed to delete category: $e");
    }
  }

  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection('categories').orderBy('categoryName').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return CategoryModel.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      },
    );
  }
}
