import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plant_app/constant.dart';
import 'package:plant_app/screens/user/camera/simple_camera_page.dart';
import 'package:plant_app/screens/user/camera/storage_helper.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      await _requestPermissions();

      final File? imageFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(builder: (context) => SimpleCameraPage()),
      );

      if (imageFile != null) {
        await _saveAndUpdateProfileImage(imageFile);
      }
    } catch (e) {
      print('Camera error: $e');
      _showErrorSnackBar('Gagal mengambil foto dari kamera');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      await _requestPermissions();

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (picked != null) {
        final File imageFile = File(picked.path);
        await _saveAndUpdateProfileImage(imageFile);
      }
    } catch (e) {
      print('Gallery error: $e');
      _showErrorSnackBar('Gagal memilih foto dari galeri');
    }
  }

  Future<void> _saveAndUpdateProfileImage(File imageFile) async {
    try {
      final File savedImage = await StorageHelper.saveImage(
        imageFile,
        'profile',
      );

      setState(() {
        _profileImage = savedImage;
      });

      _showSuccessSnackBar('Foto profil berhasil diperbarui');
    } catch (e) {
      _showErrorSnackBar('Gagal menyimpan foto profil');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Pilih Sumber Foto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kTextColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImageSourceOption(
                            icon: Icons.camera_alt,
                            label: 'Kamera',
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromCamera();
                            },
                          ),
                          _buildImageSourceOption(
                            icon: Icons.photo_library,
                            label: 'Galeri',
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromGallery();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: kPrimaryColor),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: kTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: kTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            _profileImage != null
                                ? Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                                : Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceActionSheet,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              _buildInfoCard(
                title: 'Informasi Pribadi',
                children: [
                  _buildInfoItem(
                    icon: Icons.person_outline,
                    label: 'Nama',
                    value: 'Pengguna',
                    onTap: () {},
                  ),
                  _buildInfoItem(
                    icon: Icons.phone_outlined,
                    label: 'No. Telepon',
                    value: '+62 812 3456 7890',
                    onTap: () {},
                  ),
                  _buildInfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    value: 'Jakarta, Indonesia',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kTextColor,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPrimaryColor, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
