import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/plant_viewmodel.dart';
import '../widgets/plant_grid_item.dart';

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

                  return RefreshIndicator(
                    onRefresh: vm.fetchPlants,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 90.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: vm.plants.length,
                      itemBuilder: (context, index) {
                        final plant = vm.plants[index];
                        return PlantGridItem(plant: plant);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Placeholder()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}