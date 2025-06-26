import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';

class PlantViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImageService _imageService = ImageService();

  List<Plant> _allPlants = [];
  List<Plant> _displayedPlants = [];

  String? _errorMessage;

  final Set<int> _plantsNeedingWater = {};

  List<Plant> get plants => _displayedPlants;
  String? get errorMessage => _errorMessage;
  Set<int> get plantsNeedingWater => _plantsNeedingWater;

  PlantViewModel() {
    fetchPlants();
  }
}