import 'dart:io';
import 'dart:typed_data';

import 'package:cliqueledger/api_helpers/clique_media.dart';
import 'package:cliqueledger/models/clique_media.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CliqueMediaTab extends StatefulWidget {
  CliqueMediaProvider cliqueMediaProvider;
  CliqueMediaTab({super.key, required this.cliqueMediaProvider});
  @override
  _CliqueMediaTab createState() =>
      _CliqueMediaTab(cliqueMediaProvider: cliqueMediaProvider);
}

class _CliqueMediaTab extends State<CliqueMediaTab> {
  CliqueMediaProvider cliqueMediaProvider;
  _CliqueMediaTab({required this.cliqueMediaProvider});
  @override
  Widget build(BuildContext context) {
    String currentCliqueId = context.read<CliqueProvider>().currentClique!.id;
    Map<String, List<CliqueMediaResponse>>? cliqueMediaMap =
        context.watch<CliqueMediaProvider>().cliqueMediaMap;
    if (cliqueMediaMap[currentCliqueId] == null ||
        cliqueMediaMap[currentCliqueId]!.isEmpty) {
      return const Scaffold(
          body: Center(
        child: (Text("No media yet")),
      ));
    } else {
      return const MediaCards();
    }
  }
}

// class MediaPreview extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     CliqueMediaProvider cliqueMediaProvider =
//         context.read<CliqueMediaProvider>();
//     return Scaffold(
//       body: Center(
//         child: Image.file(File(cliqueMediaProvider.filePath)),
//       ),
//       floatingActionButton:
//           FloatingActionButton(onPressed: () => {}, child: const Text('Send')),
//     );
//   }
// }

// class MediaPreview extends StatelessElement {

// }

class MediaCards extends StatelessWidget {
  const MediaCards({super.key});

  @override
  Widget build(BuildContext context) {
    String currentCliqueId = context.read<CliqueProvider>().currentClique!.id;

    List<CliqueMediaResponse>? medias =
        context.read<CliqueMediaProvider>().cliqueMediaMap[currentCliqueId];

    return ListView.builder(
      itemCount: medias!.length,
      itemBuilder: (context, index) {
        return MediaCard(
            media: medias[index],
            labelText: context
                .read<CliqueProvider>()
                .getMemberById(medias[index].senderId)
                .name);
      },
    );
  }
}

class MediaCard extends StatelessWidget {
  final CliqueMediaResponse media;
  final String labelText;

  const MediaCard({super.key, required this.media, required this.labelText});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 200,
              minWidth: screenWidth * 0.5,
              maxWidth: screenWidth * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 254, 246, 235),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelText,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color.fromARGB(255, 146, 12, 2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () {
                      // Navigate to full-screen image view when the card is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImageView(imageUrl: media.fileUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        media.fileUrl,
                        fit: BoxFit.cover,
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(media.createdAt).toLocal())}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true, // Enable panning
              scaleEnabled: true, // Enable scaling (zooming)
              minScale: 0.5, // Minimum zoom scale
              maxScale: 4.0, // Maximum zoom scale
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40, // Position the back button below the status bar
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}

class PickImage {
  void showPopup(BuildContext context) {
    CliqueMediaProvider cliqueMediaProvider =
        context.read<CliqueMediaProvider>();
    CliqueProvider cliqueProvider = context.read<CliqueProvider>();
    String selectedClique = cliqueProvider.currentClique!.id;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      panEnabled: true, // Enable panning
                      scaleEnabled: true, // Enable scaling (zooming)
                      minScale: 0.5, // Minimum zoom scale
                      maxScale: 4.0, // Maximum zoom scale
                      child: Image.file(
                        File(cliqueMediaProvider.filePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40, // Position the back button below the status bar
                    left: 20,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ),
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom:
                              20), // Add padding to create space at the bottom
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    CliqueMediaResponse? response =
                                        await CliqueMedia.uploadFile(
                                            File(cliqueMediaProvider.filePath),
                                            selectedClique);

                                    if (!context.mounted) return;

                                    setState(() {
                                      isLoading = false;
                                    });

                                    if (response != null) {
                                      cliqueMediaProvider.addItem(
                                          cliqueProvider.currentClique!.id,
                                          response);
                                    } else {
                                      debugPrint(
                                          "Media-tab: Response was null");
                                    }

                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Button color
                            ),
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: const Color(0xFFFFB200),
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        String filePath = await _pickImageFromGallery();
                        if (!context.mounted) return;
                        context.read<CliqueMediaProvider>().filePath = filePath;
                        context
                            .read<CliqueMediaProvider>()
                            .togglePreviewScreen();
                        Navigator.pop(context);
                        showPopup(context);
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("Gallery")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        String filePath = await _pickImageFromCamera();
                        if (!context.mounted) return;
                        context.read<CliqueMediaProvider>().filePath = filePath;
                        context
                            .read<CliqueMediaProvider>()
                            .togglePreviewScreen();
                        Navigator.pop(context);
                        showPopup(context);
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("Camera")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

//Gallery
  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnImage == null) return;

    debugPrint(returnImage.path);
    return returnImage.path;
  }

//Camera
  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;

    debugPrint(returnImage.path);
  }
}
