import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/user.dart';

class FaceRecognitionService {
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;

  FaceRecognitionService._internal();


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
      print('model:Model loaded Successfully');

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

      return _runInference(croppedFace);
    } catch (e) {
      print("camera image to inputimage failed");
    }
  }
  List<double> _runInference(Float32List inputBuffer) {
    try {
      // Output tensor shape [1, 512]
      final outputBuffer = Float32List(1 * 512);

      // Setup input and output tensors
      final inputs = [inputBuffer];
      final outputs = {0: outputBuffer}; // Using a map as required by runForMultipleInputs

      // Run inference
      _interpreter.runForMultipleInputs(inputs, outputs);

      // Convert to List<double> for storage
      return List<double>.from(outputBuffer);
    } catch (e) {
      debugPrint('Error during inference: $e');
      return [];
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


      if(convertedImage ==null)
        {
          return null;
        }
      final boundingBox = face.boundingBox;

      // Ensure bounding box is within image bounds
      int left = boundingBox.left.toInt().clamp(0, convertedImage.width - 1);
      int top = boundingBox.top.toInt().clamp(0, convertedImage.height - 1);
      int width = boundingBox.width.toInt().clamp(1, convertedImage.width - left);
      int height = boundingBox.height.toInt().clamp(1, convertedImage.height - top);

      img.Image croppedImage = img.copyCrop(
        convertedImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      // Resize to target size
      img.Image resizedImage = img.copyResize(
        croppedImage,
        width: targetSize,
        height: targetSize,
      );
      final inputBuffer = Float32List(1 * targetSize * targetSize * 3);
      int index = 0;
      for (int y = 0; y < targetSize; y++) {
        for (int x = 0; x < targetSize; x++) {
          final pixel = resizedImage.getPixel(x, y);
          inputBuffer[index++] = (pixel.r / 255) ; // Red
          inputBuffer[index++] = (pixel.g / 255) ; // Green
          inputBuffer[index++] = (pixel.b / 255) ; // Blue
        }
      }
      return inputBuffer;


    } catch (e) {
        print('Failed to convert camera YUV image to RGB image');
        return null;
    }
  }
  img.Image? _convertCameraImageToImage(CameraImage cameraImage) {
    try {
      img.Image image = img.Image(
        width: cameraImage.width,
        height: cameraImage.height,
      );

      const int shift = 8;
      const int uvRowStride = 2;
      const int uvPixelStride = 2;

      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < cameraImage.width; x++) {
        for (int y = 0; y < cameraImage.height; y++) {
          final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * cameraImage.width + x;

          final yp = cameraImage.planes[0].bytes[index];
          final up = cameraImage.planes[1].bytes[uvIndex];
          final vp = cameraImage.planes[2].bytes[uvIndex];

          // Convert YUV to RGB
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

          image.setPixelRgb(x, y, r, g, b);
        }
      }


      return image;
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  double compareFaces(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embedding dimensions do not match');
    }

    // Calculate Euclidean distance
    double sumSquared = 0;
    for (int i = 0; i < embedding1.length; i++) {
      double diff = embedding1[i] - embedding2[i];
      sumSquared += diff * diff;
    }

    return sumSquared;
  }

  bool isSamePerson(List<double> embedding1, List<double> embedding2, {double threshold = 0.7}) {
    double distance = compareFaces(embedding1, embedding2);
    // Lower distance means higher similarity
    return distance < threshold;
  }

  Future<User?> findMatchingUser(List<double> faceEmbedding, List<User> users) async {
    if (users.isEmpty) return null;

    double bestMatch = double.infinity;
    User? matchedUser;

    for (final user in users) {
      double distance = compareFaces(faceEmbedding, user.faceEmbedding);
      if (distance < bestMatch) {
        bestMatch = distance;
        matchedUser = user;
      }
    }

    // If best match below threshold, return the user
    if (bestMatch < 0.7) {
      return matchedUser;
    }

    return null;
  }
  void dispose()
  {
    _interpreter.close();
    _faceDetector.close();
  }


}
