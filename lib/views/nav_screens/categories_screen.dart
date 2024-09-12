import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController categoryNameController = TextEditingController();
  String? _categoryError; // Error message holder

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

  Future<String> _uploadCategoryToStorage(dynamic image) async {
    var ref = _storage.ref().child('categories').child(_fileName!);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> _uploadCategoryToFirestore() async {
    // Validate both image and category name
    if (_image != null && categoryNameController.text.isNotEmpty) {
      EasyLoading.show();
      String imageURL = await _uploadCategoryToStorage(_image);
      await _firestore.collection('categories').doc(_fileName).set({
        'categoryName': categoryNameController.text,
        'bannerImage': imageURL,
      }).whenComplete(() {
        EasyLoading.dismiss();
        setState(() {
          _image = null;
          categoryNameController.clear();
          _categoryError = null; // Clear error when successful
        });
      });
    } else {
      // Set error message if category name is empty
      setState(() {
        if (categoryNameController.text.isEmpty) {
          _categoryError = "Please enter a category name";
        } else {
          _categoryError = null;
        }
      });
      EasyLoading.showError("Please select an image and enter a category name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories', style: GoogleFonts.lato()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Category',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, fontSize: 24,
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
                Expanded(
                  child: TextField(
                    controller: categoryNameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: GoogleFonts.lato(),
                      border: const OutlineInputBorder(),
                      errorText: _categoryError, // Display error if not null
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column (
                  children: [
                    ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Select Image', style: GoogleFonts.lato()),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: _uploadCategoryToFirestore,
                      child: Text('Save', style: GoogleFonts.lato()),
                    ),
                  ]
                )
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Uploaded Categories',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      childAspectRatio: 1, // 1:1 aspect ratio
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final categoryData = categories[index].data() as Map<String, dynamic>;
                      final categoryUrl = categoryData['bannerImage'];
                      final categoryName = categoryData['categoryName'];

                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              height: 150,
                              width: 150,
                              imageUrl: categoryUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            categoryName,
                            style: GoogleFonts.lato(),
                          ),
                        ],
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
