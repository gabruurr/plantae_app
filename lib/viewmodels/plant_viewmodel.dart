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

  void _checkWateringNeeds() {
    bool changed = false;
    for (var plant in _allPlants) {
      final difference =
          DateTime.now().difference(plant.lastWatered).inSeconds;
      if (difference >= plant.wateringFrequencySeconds) {
        if (_plantsNeedingWater.add(plant.id!)) changed = true;
      } else {
        if (_plantsNeedingWater.remove(plant.id!)) changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> _handleApiOperation(Future<void> Function() operation) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await operation();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchPlants() async {
    notifyListeners();
    try {
      _allPlants = await _apiService.getPlants();
      _displayedPlants = List.from(_allPlants);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
    _checkWateringNeeds();
  }


  Future<bool> addPlant({
    required String name,
    required String species,
    required String careNotes,
    required File imageFile,
    required int wateringFrequencySeconds,
  }) async {
    bool success = true;
    await _handleApiOperation()
    return success;
  }
}