import 'dart:developer';
import 'dart:io';

import '../../../controller/auth_controller.dart';
import '../../../controller/profile_controller.dart';
import '../../../route_helper/route_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_button.dart';
import '../../../utils/snackBar.dart';
import '../../../utils/text_field.dart';
import '../../../utils/web_auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController controller = Get.put(ProfileController());

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    controller.fetchDriverDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final wide = WebAuthLayout.isWide(context);

    return Obx(() {
      return Scaffold(
        backgroundColor: wide ? const Color(0xFFF8FAFA) : Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: !wide,
          iconTheme: const IconThemeData(color: MyColors.white),
          backgroundColor: MyColors.primary,
          title: Text(
            'Profile'.tr,
            style: TextStyle(
              fontSize: wide ? 18 : 20,
              color: MyColors.white,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: true,
        ),
        body: controller.fetchDetailLoader.value
            ? Center(child: myIndicator())
            : Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 24 : 10,
                    vertical: wide ? 28 : 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: wide ? 520 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        _buildAvatarSection(wide),
                        const SizedBox(height: 14),
                        Text(
                          '${controller.Name.value} ${controller.lastName.value}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MyColors.primary,
                            fontSize: wide ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: wide ? 20 : 10),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 0 : 60,
                            vertical: 10,
                          ),
                          child: custom_buttons(
                            voidCallback: () {
                              Get.toNamed(
                                RouteHelper.getEditProfileScreenRoute(),
                              );
                            },
                            text: 'Edit Profile'.tr,
                          ),
                        ),
                        SizedBox(height: wide ? 20 : 20),
                        _buildProfileInfoCard(wide),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildAvatarSection(bool wide) {
    const avatarSize = 120.0;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: MyColors.primary.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen()),
                  );
                },
                child: controller.updateImageLoader.value
                    ? Center(
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: myIndicator(),
                        ),
                      )
                    : FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loader.gif',
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        image: controller.Image.value,
                        imageErrorBuilder: (c, o, s) => Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: MyColors.buttonColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => takePhoto(ImageSource.gallery),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: MyColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(
        source: source,imageQuality: 60);
    print("picked file -----$pickedFile");
    if (pickedFile != null) {
      controller.imageString.value = File(pickedFile.path);
      log('image path---------->:${controller.imageString.value}');
      controller.updateDriverProfile(controller.imageString.value);
    } else {
      print('No image selected.');
    }
  }
  Widget _buildProfileInfoCard(bool wide) {
    return Card(
      elevation: wide ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(wide ? 20 : 16),
        child: Column(
          children: [
            _buildInfoRow(Icons.person, "Full Name",
                "${controller.Name.value} ${controller.lastName.value}"),
            Divider(height: 32),
            _buildInfoRow(Icons.phone, "Contact Number",
                "${controller.CountryCode.value} ${controller.Contact.value}"),
            // Uncomment if needed
            // Divider(height: 32),
            // _buildInfoRow(Icons.email, "Email Address", controller.Email.value),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: MyColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: MyColors.primary, size: 24),
      ),
      title: Text(title, style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w600)),
      contentPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class DetailScreen extends StatelessWidget {
  ProfileController controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
          child: PhotoView(
            imageProvider: NetworkImage(controller.Image.value,),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 1,
            enableRotation: false,
            initialScale: PhotoViewComputedScale.contained * 1,

          )
      ),
    );

   /* DoubleTappableInteractiveViewer(
        scaleDuration: const Duration(milliseconds: 600),
    child: Image.network(controller.Image.value,height: double.infinity,width: double.infinity,));*/
  }
}


