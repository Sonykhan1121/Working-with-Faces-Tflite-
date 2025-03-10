import 'package:flutter/material.dart';
import 'package:work_with_faces/services/face_recogniton_service.dart';

import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FaceRecognitionService _faceService = FaceRecognitionService();

  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setLoading(true);
    await _faceService.loadModel();
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required List<double> faceEmbedding,
  }) async {
    try {
      _setLoading(true);
      _setError('');

      final existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        _setError('User with this email already exists');
        _setLoading(false);
        return false;
      }
      final user = User(
        name: name,
        email: email,
        password: password,
        faceEmbedding: faceEmbedding,
      );
      final userId = await _databaseService.insertUser(user);
      if (userId > 0) {
        _currentUser = user;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to register user');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('error during registration');
    }
    return false;
  }

  Future<bool> loginWithEmailPassword(String email,String password) async {
    try{
    _setLoading(true);
    _setError('');
    final isValid = await _databaseService.validateUser(email, password);
    if(isValid) {
      _currentUser = await _databaseService.getUserByEmail(email);
      _setLoading(false);
      notifyListeners();
      return true;
    }
        else
          {
            _setError('Invalid email or password');
            _setLoading(false);
            return false;
          }



    }
    catch(e)
    {
      _setError('error during login');
      _setLoading(false);
    }
    return false;
  }

  Future<User?> loginWithFace(List<double> faceEmbeddings) async {
    try {
      _setLoading(true);
      _setError('');

      final users = await _databaseService.getAllUsers();
      final matchedUser = await _faceService.findMatchingUser(faceEmbeddings,users);
      if (matchedUser != null) {
        _currentUser = matchedUser;
        _setLoading(false);
        notifyListeners();
        return matchedUser;
      }
      else
        {
          _setError('No matching user found');
          _setLoading(false);
          return null;
        }

    }
    catch(e)
    {
      _setError('No matching user found');
      _setLoading(false);
      return null;
    }

  }
  void logout()
  {
    _currentUser = null;
    notifyListeners();
  }

}
