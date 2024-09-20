import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_store_app_admin/models/banner_model.dart';

class BannerController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadBannerImage(Uint8List image, String fileName) async {
    try {
      var ref = _storage.ref().child('banners').child(fileName);
      UploadTask uploadTask = ref.putData(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload banner image: $e");
    }
  }

  Future<void> addBanner(BannerModel banner) async {
    try {
      await _firestore.collection('banners').add(banner.toMap());
    } catch (e) {
      throw Exception("Failed to add banner: $e");
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _firestore.collection('banners').doc(bannerId).delete();
    } catch (e) {
      throw Exception("Failed to delete banner: $e");
    }
  }

  Future<void> updateBannerOrder(List<BannerModel> banners) async {
    WriteBatch batch = _firestore.batch();

    try {
      // Add updates for each banner in the batch
      for (int i = 0; i < banners.length; i++) {
        DocumentReference bannerRef = _firestore.collection('banners').doc(banners[i].id);
        batch.update(bannerRef, {
          'viewOrder': i, // Update viewOrder in Firestore with the correct index
        });
      }

      // Commit the batch of updates
      await batch.commit();
      print("Banner order updated successfully!");

    } catch (e) {
      throw Exception("Failed to update banner order: $e");
    }
  }

  // Fetch banners from Firestore and convert them to BannerModel
  Stream<List<BannerModel>> getBanners() {
    return _firestore.collection('banners').orderBy('viewOrder').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return BannerModel.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      },
    );
  }
}
