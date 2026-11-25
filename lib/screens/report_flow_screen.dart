import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

const _reportBlue = Color(0xFF2864ED);
const _reportNavy = Color(0xFF20365D);
const _reportCanvas = Color(0xFFF0F5FF);
const _reportBorder = Color(0xFFDCE5F4);

class ReportDraft {
  const ReportDraft({
    required this.category,
    required this.description,
    required this.location,
    this.photoBytes,
  });

  final String category;
  final String description;
  final String location;
  final Uint8List? photoBytes;
}

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  static const _categories = <_ProblemCategory>[
    _ProblemCategory('Cleanliness', Icons.cleaning_services_outlined),
    _ProblemCategory('Safety Issue', Icons.shield_outlined),
    _ProblemCategory('Water Facilities', Icons.water_drop_outlined),
    _ProblemCategory('Overcrowding', Icons.groups_outlined),
    _ProblemCategory('Parking', Icons.local_parking_outlined),
    _ProblemCategory('Infrastructure', Icons.construction_outlined),
    _ProblemCategory('Others', Icons.more_horiz_rounded),
  ];

  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedCategory;
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DDE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add a Photo',
                style: TextStyle(
                  color: _reportNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                key: const Key('photo-source-camera'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Open Camera'),
                onTap: () => Navigator.pop(context, _PhotoSource.camera),
              ),
              ListTile(
                key: const Key('photo-source-files'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Select from Files'),
                onTap: () => Navigator.pop(context, _PhotoSource.files),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || source == null) return;
    if (source == _PhotoSource.files) {
      await _selectPhotoFromFiles();
    } else {
      await _capturePhoto();
    }
  }

  Future<void> _selectPhotoFromFiles() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final extension = image.name.split('.').last.toLowerCase();
      const supportedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
      if (!supportedExtensions.contains(extension)) {
        _showMessage('Choose a JPG, JPEG, PNG, or WebP image.');
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
    } on PlatformException {
      _showMessage('Could not open the selected image. Please try again.');
    } on MissingPluginException {
      _showMessage('Image selection is not available on this device.');
    } on UnsupportedError {
      _showMessage('This device does not support selecting an image.');
    }
  }

  Future<void> _capturePhoto() async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(builder: (_) => const ReportCameraScreen()),
    );
    if (bytes != null && mounted) {
      setState(() => _photoBytes = bytes);
    }
  }

  void _continueToReview() {
    final category = _selectedCategory;
    if (category == null) {
      _showMessage('Please select a problem category to continue.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewYourReportScreen(
          draft: ReportDraft(
            category: category,
            description: _descriptionController.text.trim(),
            location: 'Not provided',
            photoBytes: _photoBytes,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReportFlowFrame(
      primaryAction: _PrimaryReportButton(
        key: const Key('report-continue-review'),
        label: 'Continue to Review',
        onPressed: _continueToReview,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 92),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ReportStepHeader(step: 1),
                const SizedBox(height: 18),
                const Text(
                  'Report a Problem',
                  style: TextStyle(
                    color: _reportNavy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Help us make this destination better for everyone.',
                  style: TextStyle(
                    color: Color(0xFF66758D),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('What type of problem are you reporting?'),
                const SizedBox(height: 12),
                GridView.builder(
                  key: const Key('report-category-grid'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.25,
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = category.label == _selectedCategory;
                    return _CategoryTile(
                      category: category,
                      selected: selected,
                      onTap: () =>
                          setState(() => _selectedCategory = category.label),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Describe the problem'),
                const SizedBox(height: 10),
                TextField(
                  key: const Key('report-description'),
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Tell us a little more about what happened...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA6B8),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _reportBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _reportBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const _SectionLabel('Add a photo'),
                    const SizedBox(width: 8),
                    const Text(
                      '(optional)',
                      style: TextStyle(color: Color(0xFF8995A9), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_photoBytes case final bytes?)
                  _SelectedPhoto(
                    bytes: bytes,
                    onReplace: _addPhoto,
                    onRemove: () => setState(() => _photoBytes = null),
                  )
                else
                  OutlinedButton.icon(
                    key: const Key('report-add-photo'),
                    onPressed: _addPhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add a Photo'),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: _reportBlue,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: _reportBorder),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewYourReportScreen extends StatelessWidget {
  const ReviewYourReportScreen({required this.draft, super.key});

  final ReportDraft draft;

  void _submit(BuildContext context) {
    final reportId = _generateReportId();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ReportSubmittedScreen(reportId: reportId),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReportFlowFrame(
      primaryAction: _PrimaryReportButton(
        key: const Key('report-submit'),
        label: 'Submit Report',
        onPressed: () => _submit(context),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 92),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ReportStepHeader(step: 2),
                const SizedBox(height: 18),
                const Text(
                  'Review Your Report',
                  style: TextStyle(
                    color: _reportNavy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please check the details before submitting.',
                  style: TextStyle(
                    color: Color(0xFF66758D),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                _ReviewSection(
                  title: 'CATEGORY',
                  child: Text(
                    draft.category,
                    key: const Key('review-category'),
                    style: const TextStyle(
                      color: _reportNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ReviewSection(
                  title: 'LOCATION',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: _reportBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          draft.location,
                          key: const Key('review-location'),
                          style: const TextStyle(
                            color: _reportNavy,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ReviewSection(
                  title: 'DESCRIPTION',
                  child: Text(
                    draft.description.isEmpty
                        ? 'No description provided.'
                        : draft.description,
                    key: const Key('review-description'),
                    style: const TextStyle(
                      color: Color(0xFF45556E),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ReviewSection(
                  title: 'PHOTO',
                  child: draft.photoBytes == null
                      ? const Row(
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: Color(0xFF8995A9),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'No photo added',
                              style: TextStyle(
                                color: Color(0xFF66758D),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            draft.photoBytes!,
                            key: const Key('review-photo'),
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              height: 80,
                              child: Center(
                                child: Text('Photo preview unavailable'),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportSubmittedScreen extends StatelessWidget {
  const ReportSubmittedScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    return _ReportFlowFrame(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 92),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDF5E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF28A66A),
                    size: 58,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Report Submitted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _reportNavy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thank you for helping us improve this destination.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF66758D),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _reportBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'REPORT ID',
                        style: TextStyle(
                          color: Color(0xFF66758D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        reportId,
                        key: const Key('report-id'),
                        style: const TextStyle(
                          color: _reportNavy,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Keep this ID for reference',
                        style: TextStyle(
                          color: Color(0xFF66758D),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _PrimaryReportButton(
                  key: const Key('report-back-home'),
                  label: 'Back to Home',
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportCameraScreen extends StatefulWidget {
  const ReportCameraScreen({super.key});

  @override
  State<ReportCameraScreen> createState() => _ReportCameraScreenState();
}

class _ReportCameraScreenState extends State<ReportCameraScreen> {
  CameraController? _controller;
  String? _errorMessage;
  bool _isInitializing = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });
    }

    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        await _setCameraError('No camera was found on this device.');
        return;
      }

      final description = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } on CameraException catch (error) {
      await controller?.dispose();
      await _setCameraError(_cameraErrorMessage(error));
    } on MissingPluginException {
      await controller?.dispose();
      await _setCameraError('Camera access is not supported on this device.');
    } on PlatformException {
      await controller?.dispose();
      await _setCameraError('Could not access the camera. Please try again.');
    } on UnsupportedError {
      await controller?.dispose();
      await _setCameraError('Camera access is not supported on this device.');
    }
  }

  Future<void> _setCameraError(String message) async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isInitializing = false;
    });
  }

  String _cameraErrorMessage(CameraException error) {
    if (error.code.toLowerCase().contains('denied')) {
      return 'Camera permission was denied. Allow camera access in your device settings, then try again.';
    }
    if (error.code.toLowerCase().contains('restricted')) {
      return 'Camera access is restricted on this device.';
    }
    return 'Could not open the camera. Check that it is connected and try again.';
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      if (mounted) Navigator.of(context).pop(bytes);
    } on CameraException catch (error) {
      await _setCameraError(_cameraErrorMessage(error));
    } on MissingPluginException {
      await _setCameraError('Camera capture is not supported on this device.');
    } on PlatformException {
      await _setCameraError(
        'The photo could not be captured. Please try again.',
      );
    } on UnsupportedError {
      await _setCameraError('Camera capture is not supported on this device.');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Take a Photo'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: _initializeCamera,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            : _isInitializing || controller == null
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                children: [
                  Expanded(child: Center(child: CameraPreview(controller))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    child: IconButton.filled(
                      key: const Key('camera-capture'),
                      onPressed: _isCapturing ? null : _takePicture,
                      icon: _isCapturing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: _reportBlue,
                        foregroundColor: Colors.white,
                        fixedSize: const Size(64, 64),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ReportFlowFrame extends StatelessWidget {
  const _ReportFlowFrame({required this.child, this.primaryAction});

  final Widget child;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _reportCanvas,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              right: 18,
              bottom: 14,
              child: _ReportChatButton(onPressed: () => _openChat(context)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (primaryAction != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SizedBox(width: double.infinity, child: primaryAction),
              ),
            ),
          const _ReportBottomNavigation(),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReportChatSheet(),
    );
  }
}

class _ReportBottomNavigation extends StatefulWidget {
  const _ReportBottomNavigation();

  @override
  State<_ReportBottomNavigation> createState() =>
      _ReportBottomNavigationState();
}

class _ReportBottomNavigationState extends State<_ReportBottomNavigation> {
  static const _tabs = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.chat_bubble_outline_rounded, 'Guide'),
    (Icons.verified_user_outlined, 'Safety'),
    (Icons.person_outline_rounded, 'You'),
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5F9),
          border: Border(top: BorderSide(color: Color(0xFFE7E1E9))),
        ),
        child: Row(
          children: [
            for (var index = 0; index < _tabs.length; index++)
              Expanded(
                child: InkWell(
                  key: Key('report-tab-$index'),
                  onTap: () {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      setState(() => _selectedTab = index);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[index].$1,
                        size: 19,
                        color: _selectedTab == index
                            ? const Color(0xFF6650B6)
                            : const Color(0xFF777180),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _tabs[index].$2,
                        style: TextStyle(
                          fontSize: 10,
                          color: _selectedTab == index
                              ? const Color(0xFF6650B6)
                              : const Color(0xFF777180),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportChatButton extends StatelessWidget {
  const _ReportChatButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFD000),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        key: const Key('report-chat-toggle'),
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.chat_bubble_rounded,
            color: Color(0xFF302A24),
            size: 25,
          ),
        ),
      ),
    );
  }
}

class _ReportChatSheet extends StatefulWidget {
  const _ReportChatSheet();

  @override
  State<_ReportChatSheet> createState() => _ReportChatSheetState();
}

class _ReportChatSheetState extends State<_ReportChatSheet> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Material(
          color: const Color(0xFFFFF8D8),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Hello! So how may I help you?',
                        style: TextStyle(
                          color: _reportNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                TextField(
                  key: const Key('report-chat-message'),
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _messageController.clear(),
                  decoration: InputDecoration(
                    hintText: 'What would you like to know?',
                    suffixIcon: IconButton(
                      tooltip: 'Send message',
                      onPressed: _messageController.clear,
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportStepHeader extends StatelessWidget {
  const _ReportStepHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: IconButton(
            key: const Key('report-back'),
            tooltip: 'Go back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: _reportNavy,
          ),
        ),
        const Spacer(),
        Text(
          'STEP $step OF 3',
          style: const TextStyle(
            color: Color(0xFF66758D),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _reportNavy,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProblemCategory {
  const _ProblemCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _ProblemCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? _reportBlue : const Color(0xFF52627A);
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: Material(
        color: selected ? const Color(0xFFE1EBFF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('category-${category.label}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? _reportBlue : _reportBorder,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(category.icon, size: 20, color: foreground),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _reportBlue,
                    size: 17,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedPhoto extends StatelessWidget {
  const _SelectedPhoto({
    required this.bytes,
    required this.onReplace,
    required this.onRemove,
  });

  final Uint8List bytes;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _reportBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              key: const Key('report-photo-preview'),
              width: 84,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 84,
                height: 72,
                color: _reportCanvas,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Photo attached',
                  style: TextStyle(
                    color: _reportNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  key: const Key('report-replace-photo'),
                  onPressed: onReplace,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Replace photo'),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('report-remove-photo'),
            tooltip: 'Remove photo',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFF66758D),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _reportBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF66758D),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

class _PrimaryReportButton extends StatelessWidget {
  const _PrimaryReportButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _reportBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

enum _PhotoSource { camera, files }

String _generateReportId() {
  final year = DateTime.now().year;
  final suffix = Random.secure().nextInt(1000000).toString().padLeft(6, '0');
  return 'RPT-$year-$suffix';
}
