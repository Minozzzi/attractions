import 'package:attractions/src/application/attraction_create_service.dart';
import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AttractionCreate extends StatefulWidget {
  final AttractionRepository attractionRepository;

  const AttractionCreate({Key? key, required this.attractionRepository})
      : super(key: key);

  @override
  AttractionCreateState createState() => AttractionCreateState();
}

class AttractionCreateState extends State<AttractionCreate> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final differentialsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Criar Atração'),
        ),
        body: _createBody());
  }

  Widget _createBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome da atração';
                }
                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a descrição da atração';
                }
                return null;
              },
              onSaved: (value) {},
            ),
            TextFormField(
              controller: differentialsController,
              decoration: const InputDecoration(
                labelText: 'Diferenciais',
              ),
              onSaved: (value) {},
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createAttraction,
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createAttraction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final service = AttractionCreateService(widget.attractionRepository);
      final Attraction newAttraction = Attraction(
          id: Random().nextInt(1001),
          name: nameController.text,
          description: descriptionController.text,
          differentials: differentialsController.text,
          createdAt: DateTime.now());
      await service.createAttraction(newAttraction);
      Navigator.pop(context, newAttraction);
    }
  }
}
