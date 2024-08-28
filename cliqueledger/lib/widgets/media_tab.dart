import 'dart:io';


import 'package:cliqueledger/api_helpers/clique_media.dart';
import 'package:cliqueledger/models/clique_media.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/service/authservice.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CliqueMediaTab extends StatefulWidget {
  CliqueMediaProvider cliqueMediaProvider;
  CliqueMediaTab({super.key, required this.cliqueMediaProvider});
  @override
  // ignore: library_private_types_in_public_api
  _CliqueMediaTab createState() =>
      // ignore: no_logic_in_create_state
      _CliqueMediaTab(cliqueMediaProvider: cliqueMediaProvider);
}

class _CliqueMediaTab extends State<CliqueMediaTab> {
  CliqueMediaProvider cliqueMediaProvider;
  _CliqueMediaTab({required this.cliqueMediaProvider});
  @override
  Widget build(BuildContext context) {
    String currentCliqueId = context.read<CliqueProvider>().currentClique!.id;
    // Map<String, List<CliqueMediaResponse>>? cliqueMediaMap =
    //     context.watch<CliqueMediaProvider>().cliqueMediaMap;

    if (cliqueMediaProvider.cliqueMediaMap[currentCliqueId] == null ||
        cliqueMediaProvider.cliqueMediaMap[currentCliqueId]!.isEmpty) {
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

class MediaCards extends StatefulWidget {
  const MediaCards({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MediaCardsState createState() => _MediaCardsState();
}

class _MediaCardsState extends State<MediaCards> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    String currentCliqueId = context.read<CliqueProvider>().currentClique!.id;

    List<CliqueMediaResponse>? medias =
        context.read<CliqueMediaProvider>().cliqueMediaMap[currentCliqueId];

    return Consumer<CliqueMediaProvider>(
      builder: (context, cliqueMediaProvider, child) {
        // Scroll to the bottom when new items are added
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: medias!.length,
          itemBuilder: (context, index) {
            if (medias[index].mediaId != "DUMMY") {
              return MediaCard(
                media: medias[index],
                user: context
                    .read<CliqueProvider>()
                    .getMemberById(medias[index].senderId),
              );
            }
            return ImageWithLoadingOverlay(imageUrl: medias[index].fileUrl);
          },
        );
      },
    );
  }
}


class MediaCard extends StatelessWidget {
  final CliqueMediaResponse media;
  final Member user;

  const MediaCard({
    super.key,
    required this.media,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    
    final currentUserId = Authservice.instance.profile!.cliqueLedgerAppUid;
    final senderUserId = user.userId;
    final bool isCurrentUserSender = currentUserId == senderUserId;
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Align(
        alignment: isCurrentUserSender
            ? Alignment.centerRight
            : Alignment.centerLeft, // Align based on the sender
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
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: theme.textTheme.bodyLarge?.color,
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
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(media.createdAt).toLocal())}',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageWithLoadingOverlay extends StatelessWidget {
  final String imageUrl;

  const ImageWithLoadingOverlay({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons
                .error); // Display an error icon if the image fails to load
          },
        ),
        // Loading indicator overlay
        Positioned(
          child: Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
      ],
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
    //String selectedClique = cliqueProvider.currentClique!.id;

    ThemeData theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false; // Loading state variable
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
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: IconButton.styleFrom(
                          shadowColor: Colors.black,
                          backgroundColor:
                              const Color.fromRGBO(0, 0, 0, 0.2)),
                    ),
                  ),
                  // Loading icon
                  if (isLoading)
                    const Positioned(
                      child: Center(
                        child: CircularProgressIndicator(),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            
                            onPressed: () async {
                              setState(() {
                                isLoading = true; // Show loading indicator
                              });

                              File file = File(cliqueMediaProvider.filePath);
                              String cliqueId =
                                  cliqueProvider.currentClique!.id;
                              // String uid = Authservice
                              //     .instance.profile!.cliqueLedgerAppUid;

                              // CliqueMediaResponse dummyData =
                              //     CliqueMediaResponse(
                              //         mediaId: "DUMMY",
                              //         cliqueId: cliqueId,
                              //         fileUrl: cliqueMediaProvider.filePath,
                              //         createdAt: DateTime.now().toString(),
                              //         mediaType: "application/octet-stream",
                              //         senderId: cliqueProvider
                              //             .getMemberByUserId(uid)
                              //             .memberId);
                              // cliqueMediaProvider.addItem(cliqueId, dummyData);
                              // debugPrint("Dummy data added");

                              CliqueMediaResponse? newMedia =
                                  await CliqueMedia.uploadFile(
                                      file, cliqueId);

                              // Hide loading indicator
                              setState(() {
                                isLoading = false;
                              });

                              // cliqueMediaProvider.deleteByMediaId(
                              //     newMedia!.cliqueId, "DUMMY");
                              if(newMedia == null) return;

                              cliqueMediaProvider.addItem(
                                  newMedia.cliqueId, newMedia);

                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.primary, // Button color
                            ),
                            
                            child: Text(
                              'Send',
                              style: TextStyle(
                                  color:
                                      theme.textTheme.titleSmall?.color),
                            ),
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
    ThemeData theme = Theme.of(context);

    showModalBottomSheet(
        backgroundColor: theme.colorScheme.surface,
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
    return returnImage.path;
  }
}
