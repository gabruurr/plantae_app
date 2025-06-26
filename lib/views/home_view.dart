import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/plant_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlantViewModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Plantae'),
          centerTitle: false,
        ),
        body: Placeholder());
  }
}
