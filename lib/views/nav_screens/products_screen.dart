import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app_admin/controllers/product_controller.dart';
import 'package:multi_store_app_admin/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductController _productController = ProductController();
  List<ProductModel> products = [];
  List<Uint8List?> _images = [];
  List<String> _imageUrls = [];
  String? selectedCategory;

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _productController.getProducts().listen((productList) {
      setState(() {
        products = productList;
      });
    });
  }

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

  Future<void> _saveProduct() async {
    if (_images.isNotEmpty && productNameController.text.isNotEmpty) {
      EasyLoading.show();

      for (var i = 0; i < _images.length; i++) {
        String imageName = '${productNameController.text}_$i';
        String imageUrl =
            await _productController.uploadProductImage(_images[i]!, imageName);
        _imageUrls.add(imageUrl);
      }

      ProductModel product = ProductModel(
        id: '',
        productName: productNameController.text,
        price: double.tryParse(priceController.text) ?? 0,
        discount: double.tryParse(discountController.text) ?? 0,
        quantity: int.tryParse(quantityController.text) ?? 1,
        description: descriptionController.text,
        category: selectedCategory ?? '',
        size: sizeController.text,
        images: _imageUrls,
      );
      await _productController.addProduct(product);

      EasyLoading.dismiss();
      setState(() {
        _images = [];
        _imageUrls = [];
        _clearFormFields();
      });
    } else {
      EasyLoading.showError("Please fill out all fields and upload images.");
    }
  }

  void _clearFormFields() {
    productNameController.clear();
    priceController.clear();
    discountController.clear();
    quantityController.clear();
    descriptionController.clear();
    sizeController.clear();
    selectedCategory = null;
  }

  Future<void> _deleteProduct(String productId) async {
    await _productController.deleteProduct(productId);
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add New Product', style: GoogleFonts.lato()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Discount (%)',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sizeController,
                      decoration: InputDecoration(
                        labelText: 'Size',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: _productController.getCategories(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final categories = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: selectedCategory,
                          hint: const Text('Select Category'),
                          items: categories.map((doc) {
                            final categoryName = doc['categoryName'];
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
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Select Images'),
                    ),
                    const SizedBox(height: 10),
                    Text('${_images.length} image(s) selected'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: GoogleFonts.lato()),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveProduct();
                    Navigator.of(context).pop();
                  },
                  child: Text('Save Product', style: GoogleFonts.lato()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products', style: GoogleFonts.lato()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _showAddProductDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 5),
                  Text('New Product', style: GoogleFonts.lato()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Products',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(product.productName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: \$${product.price.toStringAsFixed(2)}'),
                          Text('Discount: ${product.discount}%'),
                          Text('Quantity: ${product.quantity}'),
                          Text('Category: ${product.category}'),
                          Text('Size: ${product.size}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(product.id);
                        },
                      ),
                    ),
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
