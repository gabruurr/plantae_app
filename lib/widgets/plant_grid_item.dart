import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../viewmodels/plant_viewmodel.dart';

class PlantGridItem extends StatelessWidget {
  final Plant plant;

  const PlantGridItem({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final plantsNeedingWater =
        context.select((PlantViewModel vm) => vm.plantsNeedingWater);
    final bool needsWater = plantsNeedingWater.contains(plant.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Placeholder()));
        },
        child: Placeholder(),
      ),
    );
  }
}
