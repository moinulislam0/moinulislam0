import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';


import 'package:jwells/core/constant/app_feature_flags.dart';
import 'package:jwells/features/parent/screen/parent_screen.dart';
import 'package:jwells/features/payment/presentation/view/screens/select_subscription_plan_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/terms_of_service_screen.dart';
import 'package:jwells/features/shout/presentation/viewModel/provider/create_shout_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';
import 'package:jwells/core/services/local_storage_service/location_storage.dart';
import '../../../../profile/presentation/viewmodel/profile_provider.dart';

class CreateShoutScreen extends StatefulWidget {
  const CreateShoutScreen({super.key});

  @override
  State<CreateShoutScreen> createState() => _CreateShoutScreenState();
}

class _CreateShoutScreenState extends State<CreateShoutScreen> {
  static const Color darkBackground = Color(0xFF000000);
  static const Color primaryGreen = Color(0xFF44EF89);
  static const Color fieldBackground = Color(0xFF0A0A0A);
  static const Color darkInputOutline = Color(0xFF1E1E1E);
  static const Color inactiveText = Colors.white54;

  final TextEditingController _shoutController = TextEditingController();
  final int _maxCharacters = 250;
  String _selectedMode = 'Text';
  final List<String> _tags = ['Idea', 'Observation', 'Thought', 'Gratitude', 'Concern', 'Gossip'];
  String? _selectedTag;
  
  bool _includeLocation = true;
  bool _isAnonymous = false; 
  bool _hasAcceptedPostingTerms = false;
  bool _showPostingTermsError = false;
  String _currentAddress = "Fetching location...";
  double? _latitude;
  double? _longitude;
  bool _locationAvailable = false;
  final LocationStorage _locationStorage = LocationStorage();

  List<File> _selectedMedia = [];
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomAppBarProvider>().fetchAppBar();
      _getCurrentLocation(); 
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _currentAddress = "Fetching location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationAvailable = false;
          _includeLocation = false;
          _latitude = null;
          _longitude = null;
          _currentAddress = "Location is off. You can still post without it.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationAvailable = false;
            _includeLocation = false;
            _latitude = null;
            _longitude = null;
            _currentAddress = "Location permission denied. Posting without location is available.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationAvailable = false;
          _includeLocation = false;
          _latitude = null;
          _longitude = null;
          _currentAddress = "Location permission is blocked. You can post without location.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final locationText =
            "${place.locality ?? place.subAdministrativeArea ?? ''}, ${place.country ?? ''}";
        setState(() {
          _locationAvailable = true;
          _includeLocation = true;
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentAddress = locationText;
          if (_currentAddress == ", ") _currentAddress = "Unknown location";
        });
        await _locationStorage.saveLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          locationText: _currentAddress,
        );
      }
      
    } catch (e) {
      debugPrint("Location Error: $e");
      setState(() {
        _locationAvailable = false;
        _includeLocation = false;
        _latitude = null;
        _longitude = null;
        _currentAddress = "Location unavailable right now. You can still post.";
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _shoutController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> media = await picker.pickMultipleMedia();
    if (media.isNotEmpty) {
      setState(() {
        _selectedMedia.addAll(media.map((m) => File(m.path)));
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/shout_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  void _showPostOptions() {
    if (_selectedTag == null) {
      _showErrorSnackBar("Please select a Tag");
      return;
    }
    if (!_hasAcceptedPostingTerms) {
      setState(() {
        _showPostingTermsError = true;
      });
      _showErrorSnackBar("Please accept the Terms of Service before posting");
      return;
    }
    if (_selectedMode == 'Text' && _shoutController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      _showErrorSnackBar("Please add text or media");
      return;
    } else if (_selectedMode == 'Voice' && _recordedFilePath == null) {
      _showErrorSnackBar("Please record a voice note first");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
        backgroundColor: fieldBackground,
        title: const Text("Post Shout", style: TextStyle(color: Colors.white)),
        content: Text("Do you want to post this as ${_effectiveIsAnonymous ? 'Anonymous' : 'yourself'}?", 
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final isPremium =
                  context.read<CustomAppBarProvider>().isPremimum == true;
              if (isPremium) {
                _handlePost();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentMethodScreen(
                      onPurchaseSuccess: () async {
                        await context.read<CustomAppBarProvider>().fetchAppBar();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text("Confirm", style: TextStyle(color: primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handlePost() async {
    final shoutProv = context.read<CreateShoutProvider>();
    String contentToSend = "";
    File? audioToSend;
    List<File> imageFiles = [];
    List<File> videoFiles = [];

    if (_selectedMode == 'Text') {
      contentToSend = _shoutController.text.trim();
      for (var file in _selectedMedia) {
        String path = file.path.toLowerCase();
        if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi')) {
          videoFiles.add(file);
        } else {
          imageFiles.add(file);
        }
      }
    } else {
      contentToSend = "Voice Shout";
      audioToSend = File(_recordedFilePath!);
    }

    bool success = await shoutProv.postShout(
      content: contentToSend,
      category: _selectedTag!, 
      location: (_includeLocation && _locationAvailable) ? _currentAddress : "",
      latitude: (_includeLocation && _locationAvailable) ? (_latitude ?? 0.0) : 0.0,
      longitude: (_includeLocation && _locationAvailable) ? (_longitude ?? 0.0) : 0.0,
      isAnonymous: _effectiveIsAnonymous, 
      audioFile: audioToSend,
      imageFiles: imageFiles.isNotEmpty ? imageFiles : null,
      videoFiles: videoFiles.isNotEmpty ? videoFiles : null, 
    );

    if (success) {
      if (!mounted) return;
      _showSuccessSnackBar("Shout Created Successfully!"); 
      final userId = context.read<CustomAppBarProvider>().data?.id ?? '';
      if (userId.isNotEmpty) context.read<ProfileProvider>().refreshProfile(userId);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ParentScreen()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      _showErrorSnackBar(shoutProv.errorMessage ?? "Failed to post");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateShoutProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: darkBackground,
              appBar: AppBar(
                backgroundColor: darkBackground,
                elevation: 0,
                // leading: IconButton(
                //   onPressed: () => Navigator.pop(context),
                //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                // ),
                title: Text(
                  'Create a Shout',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: provider.isLoading ? null : _showPostOptions,
                    child: Text('Post', style: TextStyle(color: primaryGreen, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 10.w),
                ],
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(),
                      _buildModeToggle(),
                      SizedBox(height: 15.h),
                      if (_selectedMode == 'Text') _buildMediaOrInputArea(),
                      if (_selectedMode == 'Voice') _buildVoiceArea(),
                      SizedBox(height: 20.h),
                      _buildTagSection(),
                      SizedBox(height: 20.h),
                      _buildOptionsCard(), 
                      SizedBox(height: 18.h),
                      _buildPostingTermsCard(),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),
            if (provider.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(color: primaryGreen)),
              ),
          ],
        );
      },
    );
  }

  bool get _effectiveIsAnonymous =>
      AppFeatureFlags.enableAnonymousPosting && _isAnonymous;

  Widget _buildUserHeader() {
    return Consumer<CustomAppBarProvider>(
      builder: (context, user, _) => Padding(
        padding: EdgeInsets.only(bottom: 15.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: (_effectiveIsAnonymous || user.avatar == null)
                  ? null
                  : NetworkImage(user.avatar!),
              backgroundColor: Colors.grey[800],
              child: _effectiveIsAnonymous
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_effectiveIsAnonymous ? 'Anonymous' : (user.name ?? 'User'), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
                Text(
                  _selectedMode == 'Text' ? '${_maxCharacters - _shoutController.text.length} characters remaining' : 'Voice Mode',
                  style: const TextStyle(color: inactiveText, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          _modeBtn('Text', Icons.text_snippet_outlined),
          _modeBtn('Voice', Icons.mic_none_outlined),
        ],
      ),
    );
  }

  Widget _modeBtn(String mode, IconData icon) {
    bool isSel = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(color: isSel ? primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSel ? Colors.black : primaryGreen, size: 20),
              SizedBox(width: 8.w),
              Text(mode, style: TextStyle(color: isSel ? Colors.black : primaryGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOrInputArea() {
    return Column(
      children: [
        if (_selectedMedia.isEmpty)
          GestureDetector(
            onTap: _pickMedia,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(15), border: Border.all(color: darkInputOutline)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.perm_media_outlined, color: Colors.white),
                  Text(" Add Media ", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 160.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMedia.length,
                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final path = _selectedMedia[index].path.toLowerCase();
                    final isVideo = path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            color: Colors.grey[900],
                            width: 160.w,
                            height: 160.h,
                            child: isVideo
                                ? const Center(child: Icon(Icons.play_circle_fill, color: primaryGreen, size: 40))
                                : Image.file(_selectedMedia[index], fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMedia.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: _pickMedia,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(15)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      Text(" Add More", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        SizedBox(height: 15.h),
        Container(
          height: 140.h,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(15), border: Border.all(color: darkInputOutline)),
          child: TextField(
            controller: _shoutController,
            maxLines: null,
            maxLength: _maxCharacters,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              hintText: "What's happening in your area? *",
              hintStyle: TextStyle(color: inactiveText, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceArea() {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(15), border: Border.all(color: darkInputOutline)),
      child: _recordedFilePath == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, color: _isRecording ? Colors.red : primaryGreen, size: 30),
                SizedBox(height: 10.h),
                Text(_isRecording ? "Recording..." : "Tap to start recording", style: const TextStyle(color: Colors.white70)),
                SizedBox(height: 15.h),
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                    decoration: BoxDecoration(color: _isRecording ? Colors.red : primaryGreen, borderRadius: BorderRadius.circular(25)),
                    child: Text(_isRecording ? "Stop Recording" : "Start Recording", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: primaryGreen, size: 40),
                  onPressed: () => _audioPlayer.play(DeviceFileSource(_recordedFilePath!)),
                ),
                const Text("Voice Recorded", style: TextStyle(color: Colors.white)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _recordedFilePath = null)),
              ],
            ),
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.sell_outlined, color: Colors.white, size: 20),
            Text(" Tag *", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _tags.map((tag) {
            bool isSel = _selectedTag == tag;
            IconData tagIcon;
            switch(tag) {
              case 'Idea': tagIcon = Icons.lightbulb_outline; break;
              case 'Observation': tagIcon = Icons.visibility_outlined; break;
              case 'Thought': tagIcon = Icons.psychology_outlined; break;
              case 'Gratitude': tagIcon = Icons.favorite_border; break;
              case 'Concern': tagIcon = Icons.report_problem_outlined; break;
              case 'Gossip': tagIcon = Icons.forum_outlined; break;
              default: tagIcon = Icons.sell_outlined;
            }

            return GestureDetector(
              onTap: () => setState(() => _selectedTag = isSel ? null : tag),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSel ? primaryGreen : fieldBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSel ? primaryGreen : darkInputOutline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tagIcon, color: isSel ? Colors.black : inactiveText, size: 16),
                    SizedBox(width: 6.w),
                    Text(tag, style: TextStyle(color: isSel ? Colors.black : inactiveText, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: fieldBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: darkInputOutline)),
      child: Column(
        children: [
          if (AppFeatureFlags.enableAnonymousPosting) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF132D20), shape: BoxShape.circle),
                  child: const Icon(Icons.security, color: primaryGreen, size: 20),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Post Anonymously",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _isAnonymous
                            ? "Your identity will stay hidden on this shout."
                            : "Post with your visible profile identity.",
                        style: const TextStyle(
                          color: inactiveText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAnonymous,
                  activeThumbColor: primaryGreen,
                  onChanged: (v) => setState(() => _isAnonymous = v),
                ),
              ],
            ),
            const Divider(color: darkInputOutline, height: 25),
          ],
	   
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF132D20), shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: primaryGreen, size: 20),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Include Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_currentAddress, style: const TextStyle(color: inactiveText, fontSize: 13)),
                  ],
                ),
              ),
              Switch(
                value: _includeLocation && _locationAvailable,
                activeThumbColor: primaryGreen,
                onChanged: _locationAvailable
                    ? (v) => setState(() => _includeLocation = v)
                    : null,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: () => _getCurrentLocation(), 
              style: ElevatedButton.styleFrom(backgroundColor: darkInputOutline, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Refresh Location", style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostingTermsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: fieldBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _showPostingTermsError
              ? Colors.redAccent
              : darkInputOutline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white54,
                ),
                child: Checkbox(
                  value: _hasAcceptedPostingTerms,
                  activeColor: primaryGreen,
                  checkColor: Colors.black,
                  side: const BorderSide(color: Colors.white54),
                  onChanged: (value) {
                    setState(() {
                      _hasAcceptedPostingTerms = value ?? false;
                      if (_hasAcceptedPostingTerms) {
                        _showPostingTermsError = false;
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Wrap(
                    children: [
                      Text(
                        'I agree that I will not post objectionable content or harass other users, and I understand violations may result in an immediate ban. Read the ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          height: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsOfServiceScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                      Text(
                        '.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Posting abusive, hateful, threatening, or otherwise objectionable content is not allowed.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
          if (_showPostingTermsError)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                'You must accept the Terms of Service before posting.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
