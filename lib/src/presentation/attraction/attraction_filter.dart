import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttractionFilters extends StatefulWidget {
  const AttractionFilters({super.key});

  @override
  AttractionFiltersState createState() => AttractionFiltersState();
}

class AttractionFiltersState extends State<AttractionFilters> {
  final _formKey = GlobalKey<FormState>();
  final nameFilterController = TextEditingController();
  final descriptionFilterController = TextEditingController();
  final differentialsFilterController = TextEditingController();
  final createdAtFilterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Filtros - Atrações'),
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
            const Text('Filtrar por:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            TextFormField(
              controller: nameFilterController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
            ),
            TextFormField(
              controller: descriptionFilterController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
            ),
            TextFormField(
              controller: differentialsFilterController,
              decoration: const InputDecoration(
                labelText: 'Diferenciais',
              ),
            ),
            TextFormField(
              controller: createdAtFilterController,
              decoration: InputDecoration(
                labelText: 'Data de criação',
                prefixIcon: IconButton(
                  onPressed: _showCalendar,
                  icon: const Icon(Icons.calendar_today),
                ),
                suffixIcon: IconButton(
                  onPressed: () => createdAtFilterController.clear(),
                  icon: const Icon(Icons.close),
                ),
              ),
              readOnly: true,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: true,
                  onChanged: (bool? value) => {},
                ),
                const Text(
                  'Usar ordem decrescente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendar() async {
    final formattedDate = createdAtFilterController.text;
    DateTime date = DateTime.now();
    if (formattedDate.isNotEmpty) {
      date = DateFormat("dd/MM/yyyy").parse(formattedDate);
    }

    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: date.subtract(const Duration(days: 365 * 5)),
      lastDate: date.add(const Duration(days: 365 * 5)),
    );

    if (newDate != null) {
      setState(() {
        createdAtFilterController.text =
            DateFormat("dd/MM/yyyy").format(newDate);
      });
    }
  }
}
