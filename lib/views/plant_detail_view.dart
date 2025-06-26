import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../viewmodels/plant_viewmodel.dart';
import 'plant_form_view.dart';

import 'package:collection/collection.dart';

class PlantDetailView extends StatefulWidget {
  final int plantId;

  const PlantDetailView({super.key, required this.plantId});

  @override
  State<PlantDetailView> createState() => _PlantDetailViewState();
}

class _PlantDetailViewState extends State<PlantDetailView> {
  

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantViewModel>(
      builder: (context, viewModel, child) {
        final plant =
            viewModel.plants.firstWhereOrNull((p) => p.id == widget.plantId);

        if (plant == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(plant.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PlantFormView(plant: plant)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _showDeleteConfirmation(context, viewModel, plant),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'plant_image_${plant.id}',
                  child: Image.network(
                    plant.imageUrl,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.local_florist,
                          size: 100, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Espécie',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text(plant.species,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text('Frequência de Rega',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text(
                        'A cada ${plant.wateringFrequencySeconds} segundos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Próxima Rega em',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text(
                        _countdownText,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 14, 126, 231)),
                      ),
                      Text('Última Rega',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text(
                        DateFormat("EEEE, dd 'de' MMMM 'às' HH:mm", 'pt_BR')
                            .format(plant.lastWatered.toLocal()),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Notas de Cuidado',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text(
                        plant.careNotes.isEmpty
                            ? 'Nenhuma nota.'
                            : plant.careNotes,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.5),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.water_drop),
                        label: const Text('Regar Agora'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          _audioPlayer.play(AssetSource("audio/water.mp3"));
                          viewModel.updateWateringDate(plant.id!);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(
                                content: Text('Contador resetado!'),
                                backgroundColor: Colors.blue));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, PlantViewModel viewModel, Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              Text('Tem certeza que deseja excluir a planta "${plant.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                final viewModel =
                    Provider.of<PlantViewModel>(context, listen: false);
                viewModel.deletePlant(plant.id!);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}