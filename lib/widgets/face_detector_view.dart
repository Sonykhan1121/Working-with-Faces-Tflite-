import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

typedef FaceDetectedCallback = void Function(List<double> faceEmbedding);

class FaceDetectorView extends StatefulWidget {
  final FaceDetectedCallback onFaceDetected;
  final VoidCallback onCancel;

  const FaceDetectorView({super.key, required this.onFaceDetected, required this.onCancel});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _faceDetected = false;
  bool _processingComplete = false;
  Face? _detectedFace;

  int _consecutiveDetections = 0;
  static const int _requiredConsecutiveDetections = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) {
        return;
      }

      // await _cameraController!.startImageStream(_processCameraImage);
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("camera initialize problem");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('cameraPreview')),
      body: Stack(
        children: [
          Center(child: CameraPreview(_cameraController!)),
          if (_faceDetected)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _processingComplete ? Colors.green : Colors.blue,
                    width: 2,
                  ),
                ),
                child:
                    _processingComplete
                        ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        )
                        : null,
              ),
            ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.black,
              child: Text(
                _faceDetected
                    ? 'Hold still, capturing your face...'
                    : 'Position your face in the center of the screen',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: widget.onCancel,
                label: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical:12,

                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
