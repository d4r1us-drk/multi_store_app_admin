import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app_admin/controllers/banner_controller.dart';
import 'package:multi_store_app_admin/models/banner_model.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final BannerController _bannerController = BannerController();
  Uint8List? _image;
  String? _fileName;
  List<BannerModel> banners = [];

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    _bannerController.getBanners().listen((bannerList) {
      setState(() {
        banners = bannerList;
      });
    });
  }

  void _pickImage(StateSetter setState) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _image = result.files.first.bytes;
        _fileName = result.files.first.name;
      });
    }
  }

  Future<void> _saveBanner() async {
    if (_image != null && _fileName != null) {
      EasyLoading.show();
      String imageUrl = await _bannerController.uploadBannerImage(_image!, _fileName!);
      BannerModel banner = BannerModel(
        id: '', // Firestore genera el ID
        bannerImage: imageUrl,
        viewOrder: banners.length, // El nuevo banner va al final
      );
      await _bannerController.addBanner(banner);
      EasyLoading.dismiss();
      setState(() {
        _image = null;
        _fileName = null;
      });
    } else {
      EasyLoading.showError("Please select an image before saving");
    }
  }

  Future<void> _deleteBanner(String bannerId) async {
    await _bannerController.deleteBanner(bannerId);
  }

  // Move banner up in the list
  void _moveUp(int index) {
    if (index > 0) {
      setState(() {
        final banner = banners.removeAt(index);
        banners.insert(index - 1, banner);
      });
      _updateBannerOrder();
    }
  }

  // Move banner down in the list
  void _moveDown(int index) {
    if (index < banners.length - 1) {
      setState(() {
        final banner = banners.removeAt(index);
        banners.insert(index + 1, banner);
      });
      _updateBannerOrder();
    }
  }

  Future<void> _updateBannerOrder() async {
    try {
      // Call the batch update method in the controller
      await _bannerController.updateBannerOrder(banners);
    } catch (e) {
      EasyLoading.showError("Failed to update banner order: $e");
    }
  }

  void _showAddBannerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add New Banner', style: GoogleFonts.lato()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _image!,
                            height: 200,
                            width: 500,
                            fit: BoxFit.cover,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _pickImage(setState);
                          },
                          child: Container(
                            height: 200,
                            width: 500,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Center(
                              child: Icon(Icons.image,
                                  size: 50, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(setState);
                    },
                    child: Text('Select Image', style: GoogleFonts.lato()),
                  ),
                  const SizedBox(height: 10),
                  _image != null
                      ? Text(
                          'Selected image: $_fileName',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        )
                      : Text(
                          'No image selected',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                ],
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
                    if (_image != null) {
                      _saveBanner();
                      Navigator.of(context).pop();
                    } else {
                      EasyLoading.showError("Please select an image.");
                    }
                  },
                  child: Text('Save', style: GoogleFonts.lato()),
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
        title: Text('Manage Banners', style: GoogleFonts.lato()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _showAddBannerDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  const SizedBox(width: 5),
                  Text('New Banner', style: GoogleFonts.lato()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Banners',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: banner.bannerImage,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text('Order: ${banner.viewOrder + 1}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Up arrow
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () => _moveUp(index),
                          ),
                          // Down arrow
                          IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () => _moveDown(index),
                          ),
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteBanner(banner.id);
                            },
                          ),
                        ],
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
