import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwells/features/home/presentation/viewmodel/post_model.dart';

import 'package:jwells/features/profile/presentation/viewmodel/profile_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/shout_edit_provider.dart';

import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:provider/provider.dart';

class ShoutEditScreen extends StatefulWidget {
  final Post post;
  const ShoutEditScreen({super.key, required this.post});

  @override
  State<ShoutEditScreen> createState() => _ShoutEditScreenState();
}

class _ShoutEditScreenState extends State<ShoutEditScreen> {
  late TextEditingController _contentController;

  List<String> _existingImageUrls = [];
  List<File> _newImageFiles = [];
  String? _existingVideoUrl;
  File? _newVideoFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    if (widget.post.imageUrls != null) {
      _existingImageUrls = List.from(widget.post.imageUrls!);
    }
    _existingVideoUrl = widget.post.videoUrl;
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImageFiles.addAll(images.map((e) => File(e.path)).toList());
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _newVideoFile = File(video.path);
        _existingVideoUrl = null;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff121212),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Edit your shout...",
                          hintStyle: TextStyle(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildMediaGrid(),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildAddButton(
                            Icons.add_a_photo,
                            "Image",
                            _pickImage,
                          ),
                          const SizedBox(width: 10),
                          _buildAddButton(
                            Icons.video_call,
                            "Video",
                            _pickVideo,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._existingImageUrls.map(
          (url) => _mediaThumbnail(url: url, isFile: false),
        ),
        ..._newImageFiles.map(
          (file) => _mediaThumbnail(file: file, isFile: true),
        ),
        if (_existingVideoUrl != null)
          _mediaThumbnail(url: _existingVideoUrl, isVideo: true, isFile: false),
        if (_newVideoFile != null)
          _mediaThumbnail(file: _newVideoFile, isVideo: true, isFile: true),
      ],
    );
  }

  Widget _mediaThumbnail({
    String? url,
    File? file,
    bool isFile = false,
    bool isVideo = false,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 80,
            height: 80,
            color: Colors.white10,
            child: isVideo
                ? const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 30,
                  )
                : isFile
                ? Image.file(file!, fit: BoxFit.cover)
                : Image.network(url!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isVideo) {
                  _existingVideoUrl = null;
                  _newVideoFile = null;
                } else if (isFile) {
                  _newImageFiles.remove(file);
                } else {
                  _existingImageUrls.remove(url);
                }
              });
            },
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff2ECC71), size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xff0D1F15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Edit Shout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: widget.post.userAvatar.isNotEmpty
              ? NetworkImage(widget.post.userAvatar)
              : null,
          child: widget.post.userAvatar.isEmpty
              ? const Icon(Icons.person, size: 18)
              : null,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              widget.post.timeAgo,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<EditShoutProvider>(
      builder: (context, editProv, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: editProv.isLoading
                    ? null
                    : () async {
                        
                        bool success = await editProv.editShout(
                          id: widget.post.id,
                          content: _contentController.text,
                          category: widget.post.type.name,
                          location: widget.post.location,

                          latitude: widget.post.latitude ?? "0.0",
                          longitude: widget.post.longitude ?? "0.0",
                          isAnonymous: false,
                          imageFiles: _newImageFiles,
                          videoFile: _newVideoFile,
                        );

                        if (success && mounted) {
                          final userId =
                              context.read<CustomAppBarProvider>().data?.id ??
                              '';
                          if (userId.isNotEmpty) {
                            context.read<ProfileProvider>().refreshProfile(
                              userId,
                            );
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Post updated successfully!"),
                              backgroundColor: Color(0xff2ECC71),
                            ),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                editProv.errorMessage ?? "Update failed",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: editProv.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
