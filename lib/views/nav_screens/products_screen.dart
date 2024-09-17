import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  String? selectedCategory;
  String? _productError;
  List<Uint8List?> _images = []; // Holds the selected images
  List<String> _imageUrls = []; // Holds the uploaded image URLs

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _images = result.files.map((file) => file.bytes).toList();
      });
    }
  }

  Future<String> _uploadImageToStorage(
      Uint8List image, String imageName) async {
    Reference ref = _storage.ref().child('products').child(imageName);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _uploadProductToFirestore() async {
    // Validate the input fields
    if (productNameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        selectedCategory != null &&
        _images.isNotEmpty) {
      EasyLoading.show();

      // Upload images and collect their URLs
      for (var i = 0; i < _images.length; i++) {
        String imageName = '${productNameController.text}_$i';
        String imageUrl = await _uploadImageToStorage(_images[i]!, imageName);
        _imageUrls.add(imageUrl); // Store image URLs in list
      }

      await _firestore.collection('products').add({
        'productName': productNameController.text,
        'price': double.tryParse(priceController.text) ?? 0,
        'discount': double.tryParse(discountController.text) ?? 0,
        'quantity': int.tryParse(quantityController.text) ?? 1,
        'description': descriptionController.text,
        'category': selectedCategory,
        'size': sizeController.text,
        'images': _imageUrls, // Store image URLs in Firestore
      }).whenComplete(() {
        EasyLoading.dismiss();
        setState(() {
          // Clear the form
          productNameController.clear();
          priceController.clear();
          discountController.clear();
          quantityController.clear();
          descriptionController.clear();
          sizeController.clear();
          selectedCategory = null;
          _productError = null;
          _images = []; // Clear selected images
          _imageUrls = []; // Clear image URLs
        });
      });
    } else {
      // Show error message if fields are not filled correctly
      setState(() {
        _productError =
            "Please complete all fields and upload at least one image.";
      });
      EasyLoading.showError("Please complete all fields.");
    }
  }

  // Widget to display selected images with the option to remove them
  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return const SizedBox.shrink(); // Return nothing if no images selected
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.memory(
                    _images[index]!,
                    fit: BoxFit.cover,
                  ),
                ),
                // Remove button on the top right of each image
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Information'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Product Information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              // Product Name
              TextField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Product Name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Price and Category in a Row
              Row(
                children: [
                  // Price Field
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Price',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Category Dropdown
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('categories').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final categories = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedCategory,
                          hint: const Text('Select a Category'),
                          items: categories.map((doc) {
                            final categoryName = doc['categoryName'] as String;
                            return DropdownMenuItem<String>(
                              value: categoryName,
                              child: Text(categoryName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Discount Field
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Quantity Field
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Description Field
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Add a Size Field
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(
                  labelText: 'Add a Size',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Upload Images Section
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text('Select Images'),
                  ),
                  const SizedBox(width: 10),
                  // Show selected image count
                  Text('${_images.length} image(s) selected'),
                ],
              ),
              const SizedBox(height: 10),
              // Image Preview Widget
              _buildImagePreview(),
              const SizedBox(height: 20),
              // Add Product Button
              ElevatedButton(
                onPressed: _uploadProductToFirestore,
                child: const Text('Add Product'),
              ),
              if (_productError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _productError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
