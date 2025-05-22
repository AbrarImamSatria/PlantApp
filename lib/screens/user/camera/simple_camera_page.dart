import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class SimpleCameraPage extends StatefulWidget {
  const SimpleCameraPage({super.key});

  @override
  State<SimpleCameraPage> createState() => _SimpleCameraPageState();
}

class _SimpleCameraPageState extends State<SimpleCameraPage> {
  List<CameraDescription>? _cameras; 
  CameraController? _controller;
  int _selectedCameraIdx = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _isInitialized = false;
  bool _isCameraInitializing = false; 

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;
    
    setState(() => _isCameraInitializing = true);
    
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _setupCamera(_selectedCameraIdx);
      } else {
        print('No cameras available');
      }
    } catch (e) {
      print('Error initializing camera: $e');
    } finally {
      if (mounted) {
        setState(() => _isCameraInitializing = false);
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;
    if (cameraIndex >= _cameras!.length) return;
    
    if (_controller != null) {
      await _controller!.dispose();
    }

    final controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _controller = controller;
          _selectedCameraIdx = cameraIndex;
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error setting up camera: $e');
      if (mounted) {
        setState(() => _isInitialized = false);
      }
    }
  }

  Future<void> _captureImage() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) return;
    
    try {
      final XFile file = await _controller!.takePicture();
      Navigator.pop(context, File(file.path));
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;
    
    final newIndex = (_selectedCameraIdx + 1) % _cameras!.length;
    await _setupCamera(newIndex);
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
      default:
        nextMode = FlashMode.off;
    }
    
    await _controller!.setFlashMode(nextMode);
    setState(() => _flashMode = nextMode);
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isInitialized && _controller != null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getFlashIcon(),
                        color: _flashMode == FlashMode.off ? Colors.white : Colors.yellow,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 30,
                right: 30,
                bottom: MediaQuery.of(context).padding.bottom + 30,
                top: 30,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 60),
                  
                  GestureDetector(
                    onTap: _captureImage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  if (_cameras != null && _cameras!.length > 1)
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flip_camera_android,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}