import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadBannersScreen extends StatefulWidget {
  const UploadBannersScreen({super.key});

  @override
  State<UploadBannersScreen> createState() => _UploadBannersScreenState();
}

class _UploadBannersScreenState extends State<UploadBannersScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  dynamic _image;
  String? _fileName;

  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
        _fileName = result.files.first.name;
      });
    }
  }

  Future<String> _uploadBannerToStorage(dynamic image) async {
    var ref = _storage.ref().child('banners').child(_fileName!);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> _uploadBannerToFirestore() async {
    // Check if an image is selected
    if (_image != null) {
      EasyLoading.show();
      String imageURL = await _uploadBannerToStorage(_image);
      await _firestore.collection('banners').doc(_fileName).set({
        'bannerImage': imageURL,
      }).whenComplete(() {
        EasyLoading.dismiss();
        setState(() {
          _image = null; // Reset image after successful upload
        });
      });
    } else {
      // Show error if no image is selected
      EasyLoading.showError("Please select an image before saving");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Banners', style: GoogleFonts.lato()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Banner',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_image, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Icon(Icons.image,
                                size: 50, color: Colors.grey.shade500),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Select Image', style: GoogleFonts.lato()),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _uploadBannerToFirestore,
                      child: Text('Save Banner', style: GoogleFonts.lato()),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Uploaded Banners',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('banners').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final banners = snapshot.data!.docs;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double imageWidth = (constraints.maxWidth / 3) - 10;
                      double imageHeight = imageWidth * 10 / 16;

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 16 / 10,
                        ),
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          final bannerData = banners[index].data() as Map<String, dynamic>;
                          final bannerUrl = bannerData['bannerImage'];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: bannerUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(
                                Icons.broken_image,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
