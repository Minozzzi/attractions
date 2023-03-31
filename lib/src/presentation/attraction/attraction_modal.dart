import 'package:attractions/src/application/attraction_create_service.dart';
import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AttractionModal extends StatefulWidget {
  final AttractionCreateService attractionCreateService;
  final bool isViewOnly;
  final bool isEditing;
  final Attraction? attraction;

  const AttractionModal(
      {Key? key,
      required this.attractionCreateService,
      required this.isViewOnly,
      required this.isEditing,
      this.attraction})
      : super(key: key);

  @override
  AttractionModalState createState() => AttractionModalState();
}

class AttractionModalState extends State<AttractionModal> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final differentialsController = TextEditingController();
  late String pageTitle;

  @override
  void initState() {
    super.initState();
    if (widget.attraction == null) return;

    nameController.text = widget.attraction?.name ?? '';
    descriptionController.text = widget.attraction?.description ?? '';
    differentialsController.text = widget.attraction?.differentials ?? '';

    if (widget.isViewOnly) {
      pageTitle = 'Visualizar atração';
      return;
    }

    pageTitle = widget.isEditing
        ? 'Atualizar atração ${widget.attraction?.name}'
        : 'Criar nova atração';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
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
              enabled: !widget.isViewOnly,
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
              enabled: !widget.isViewOnly,
            ),
            TextFormField(
              controller: differentialsController,
              decoration: const InputDecoration(
                labelText: 'Diferenciais',
              ),
              enabled: !widget.isViewOnly,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isViewOnly ? null : createAttraction,
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
      final Attraction newAttraction = Attraction(
          id: Random().nextInt(1001),
          name: nameController.text,
          description: descriptionController.text,
          differentials: differentialsController.text,
          createdAt: DateTime.now());
      await widget.attractionCreateService.createAttraction(newAttraction);
      Navigator.pop(context, newAttraction);
    }
  }
}
