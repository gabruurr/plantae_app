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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: TextField(
                onChanged: (value) {
                  viewModel.searchPlants(value);
                },
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome ou espécie...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
            ),
            Expanded(
              child: Consumer<PlantViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading && vm.plants.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.errorMessage != null) {
                    return Center(
                        child: Text('Ocorreu um erro: ${vm.errorMessage}'));
                  }

                  if (vm.plants.isEmpty) {
                    return const Center(
                        child: Text('Nenhuma planta encontrada.'));
                  }

              ),
            ),
          ],
        ),
      ),
    );
  }
}