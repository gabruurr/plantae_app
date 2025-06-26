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
    bool success = false;
    await _handleApiOperation(() async {
      final imageUrl = await _imageService.uploadImage(imageFile);
      if (imageUrl == null) {
        throw Exception("Falha no upload da imagem.");
      }

      final newPlant = Plant(
        name: name,
        species: species,
        imageUrl: imageUrl,
        lastWatered: DateTime.now().toUtc(),
        careNotes: careNotes,
        wateringFrequencySeconds: wateringFrequencySeconds,
      );

      await _apiService.addPlant(newPlant);

      await fetchPlants();

      success = true;
    });
    return success;
  }

  Future<bool> updatePlant(Plant plantToUpdate) async {
    bool success = false;
    await _handleApiOperation(() async {
      await _apiService.updatePlant(plantToUpdate);
      final index = _allPlants.indexWhere((p) => p.id == plantToUpdate.id);
      if (index != -1) {
        _allPlants[index] = plantToUpdate;
      }
      await fetchPlants();
      success = true;
    });
    return success;
  }

  Future<void> updateWateringDate(int plantId) async {
    try {
      final newDate = DateTime.now().toUtc();

      await _apiService.updateLastWatered(plantId, newDate);

      final plantIndexAll = _allPlants.indexWhere((p) => p.id == plantId);
      if (plantIndexAll != -1) _allPlants[plantIndexAll].lastWatered = newDate;

      final plantIndexDisplayed =
          _displayedPlants.indexWhere((p) => p.id == plantId);
     

      notifyListeners();
    } catch (e) {
      _errorMessage = "Falha ao regar a planta: $e";
      notifyListeners();
    }
  }

  Future<void> deletePlant(int plantId) async {
    final plantIndex = _allPlants.indexWhere((p) => p.id == plantId);
    if (plantIndex == -1) return;

    final plantToRemove = _allPlants[plantIndex];

    _allPlants.removeAt(plantIndex);
    notifyListeners();

    try {
      await _apiService.deletePlant(plantId);
      _allPlants.removeWhere((p) => p.id == plantId);
      _displayedPlants.removeWhere((p) => p.id == plantId);
      notifyListeners();
    } catch (e) {
      _allPlants.insert(plantIndex, plantToRemove);
      notifyListeners();
    }
  }
}