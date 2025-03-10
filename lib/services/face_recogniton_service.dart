import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  late Interpreter _interpreter;
  late FaceDetector _faceDetector;
  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      //load model from assets
      _interpreter = await Interpreter.fromAsset(
        'assets/models/facenet_512.tflite',
        options: options,
      );

      //Initialize face detector

      final options2 = FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      );
      _faceDetector = FaceDetector(options: options2);
      _modelLoaded = true;
      debugPrint('Model loaded Successfully');
    } catch (e) {
      print('Loadmodel failed');
    }
  }

  bool get isModelLoaded => _modelLoaded;

  Future<List<double>?> getFaceEmbedding(CameraImage cameraImage) async {
    if (!_modelLoaded) await loadModel();

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageWidth = cameraImage.width;
      final imageHeight = cameraImage.height;

      final inputimage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(
            cameraImage.width.toDouble(),
            cameraImage.height.toDouble(),
          ),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: cameraImage.planes[0].bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputimage);
      if (faces.isEmpty) return null;

      final face = _getLargestFace(faces);
      final croppedFace = await _extractAndResizeFace(
        cameraImage,
        face,
        targetSize: 160,
      );
      if (croppedFace == null) return null;
    } catch (e) {
      print("camera image to inputimage failed");
    }
  }

  Face _getLargestFace(List<Face> faces) {
    Face largestFace = faces[0];
    double largestArea = _getFaceArea(largestFace);
    for (var i = 1; i < faces.length; i++) {
      double area = _getFaceArea(faces[i]);
      if (area > largestArea) {
        largestArea = area;
        largestFace = faces[i];
      }
    }

    return largestFace;
  }

  double _getFaceArea(Face face) {
    final boundingBox = face.boundingBox;
    return boundingBox.width * boundingBox.height;
  }

  Future<Float32List?> _extractAndResizeFace(
    CameraImage image,
    Face face, {
    required int targetSize,
  }) async {
    try {
      //convert YUV to RGB
      img.Image? convertedImage = _convertCameraImageToImage(image);
    } catch (e) {
        print('Failed to convert camera YUV image to RGB image');
        return null;
    }
  }
  img.Image? _convertCameraImageToImage(CameraImage image)
  {
    return null;
  }
}
