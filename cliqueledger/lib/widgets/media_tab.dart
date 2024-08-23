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
import 'package:provider/provider.dart';

class CliqueMediaTab extends StatefulWidget {
  CliqueMediaProvider cliqueMediaProvider;
  CliqueMediaTab({required this.cliqueMediaProvider});
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
    Map<String, List<CliqueMediaResponse>>? cliqueMediaMap = context.watch<CliqueMediaProvider>().cliqueMediaMap;
    if (cliqueMediaMap[currentCliqueId] == null || cliqueMediaMap[currentCliqueId]!.isEmpty) {
      return const Scaffold(
          body: Center(
        child: (Text("No media yet")),
      ));
    } else {
      return MediaCards();
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
  @override
  Widget build(BuildContext context) {
    String currentCliqueId = context.read<CliqueProvider>().currentClique!.id;

    List<CliqueMediaResponse>? medias = context
        .read<CliqueMediaProvider>()
        .cliqueMediaMap[currentCliqueId];   

    return ListView.builder(
      itemCount: medias!.length,
      itemBuilder: (context, index) {
        return MediaCard(media: medias[index]);
      },
    );
  }
}

class MediaCard extends StatelessWidget {
  final CliqueMediaResponse media;

  MediaCard({required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(media.fileUrl),
        ],
      ),
    );
  }
}

class PickImage {
  void showPopup(BuildContext context) {
    CliqueMediaProvider cliqueMediaProvider = context.read<CliqueMediaProvider>();
    CliqueProvider cliqueProvider = context.read<CliqueProvider>();
    String selectedClique = cliqueProvider.currentClique!.id;
    showDialog(
      context: context,
      
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(cliqueMediaProvider.filePath)),
              const SizedBox(height: 10),
              const Text('Do you want to send this media?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              onPressed: ()async {
                // Add your send functionality here
                print("Send button clicked!");
                CliqueMediaResponse? response = await CliqueMedia.uploadFile(File(cliqueMediaProvider.filePath), selectedClique);
                if(!context.mounted) return;
                if(response != null) {
                  cliqueMediaProvider.addItem(cliqueProvider.currentClique!.id, 
                                  response);
                }
                
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.blue[100],
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
