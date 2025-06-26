import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../viewmodels/plant_viewmodel.dart';

class PlantFormView extends StatefulWidget {
  final Plant? plant;
  const PlantFormView({super.key, this.plant});

  @override
  State<PlantFormView> createState() => _PlantFormViewState();
}

class _PlantFormViewState extends State<PlantFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _notesController;

  late final TextEditingController _frequencyController;

  File? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant?.name ?? '');
    _speciesController =
        TextEditingController(text: widget.plant?.species ?? '');
    _notesController =
        TextEditingController(text: widget.plant?.careNotes ?? '');

    _frequencyController = TextEditingController(
      text: widget.plant?.wateringFrequencySeconds.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();

    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (widget.plant == null && _imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Por favor, selecione uma imagem para a nova planta.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      final viewModel = Provider.of<PlantViewModel>(context, listen: false);
      final isEditing = widget.plant != null;
      bool success = false;

      final frequency = int.parse(_frequencyController.text);

      if (isEditing) {
        final updatedPlant = Plant(
          id: widget.plant!.id,
          createdAt: widget.plant!.createdAt,
          name: _nameController.text,
          species: _speciesController.text,
          imageUrl: widget.plant!.imageUrl,
          lastWatered: widget.plant!.lastWatered,
          careNotes: _notesController.text,
          wateringFrequencySeconds: frequency,
        );
        success = await viewModel.updatePlant(updatedPlant);
      } else {
        success = await viewModel.addPlant(
          name: _nameController.text,
          species: _speciesController.text,
          careNotes: _notesController.text,
          imageFile: _imageFile!,
          wateringFrequencySeconds: frequency,
        );
      }

      setState(() {
        _isSaving = false;
      });

      if (context.mounted) {
        if (success) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Planta salva com sucesso!'
                  : 'Erro: ${viewModel.errorMessage}'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.plant == null ? 'Adicionar Nova Planta' : 'Editar Planta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nome da Planta', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'O nome é obrigatório.'
                    : null,
              ),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                    labelText: 'Espécie', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'A espécie é obrigatória.'
                    : null,
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Regar a cada (segundos)',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: 10 para regar a cada 10 segundos',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A frequência é obrigatória.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                    labelText: 'Notas de Cuidado',
                    border: OutlineInputBorder()),
                maxLines: 4,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: _isSaving ? null : _submitForm,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white))
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity);
    }

    if (widget.plant?.imageUrl != null) {
      return Image.network(widget.plant!.imageUrl,
          fit: BoxFit.cover, width: double.infinity);
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text('Clique para adicionar uma imagem'),
      ],
    );
  }
}