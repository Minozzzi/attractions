import 'package:attractions/src/domain/attraction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttractionFilters extends StatefulWidget {
  static const keyFieldOrder = 'fieldOrder';
  static const keyAscending = 'ascending';
  static const keyFilters = 'filters';

  const AttractionFilters({super.key});

  @override
  AttractionFiltersState createState() => AttractionFiltersState();
}

class AttractionFiltersState extends State<AttractionFilters> {
  final _formKey = GlobalKey<FormState>();
  final _fieldsToOrder = {
    Attraction.FIELD_NAME: 'Nome',
    Attraction.FIELD_DESCRIPTION: 'Descrição',
    Attraction.FIELD_DIFFERENTIALS: 'Diferenciais',
    Attraction.FIELD_CREATED_AT: 'Data de criação',
  };
  late final SharedPreferences _preferences;
  String _fieldOrder = Attraction.FIELD_NAME;
  bool _ascending = true;
  bool _changeValues = false;

  final nameFilterController = TextEditingController();
  final descriptionFilterController = TextEditingController();
  final differentialsFilterController = TextEditingController();
  final createdAtFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Filtros - Atrações'),
        ),
        body: _createBody());
  }

  void _loadPreferences() async {
    _preferences = await SharedPreferences.getInstance();

    setState(() {
      _fieldOrder = _preferences.getString(AttractionFilters.keyFieldOrder) ??
          Attraction.FIELD_NAME;
      _ascending = _preferences.getBool(AttractionFilters.keyAscending) ?? true;
      final filters =
          _preferences.getString(AttractionFilters.keyFilters) ?? '';
      final filtersJson = filters.split('|');

      for (final filter in filtersJson) {
        final filterParts = filter.split(':');

        if (filterParts.length == 2) {
          final key = filterParts[0];
          final value = filterParts[1];

          switch (key) {
            case Attraction.FIELD_NAME:
              nameFilterController.text = value;
              break;
            case Attraction.FIELD_DESCRIPTION:
              descriptionFilterController.text = value;
              break;
            case Attraction.FIELD_DIFFERENTIALS:
              differentialsFilterController.text = value;
              break;
            case Attraction.FIELD_CREATED_AT:
              createdAtFilterController.text = value.isNotEmpty ? DateFormat("dd/MM/yyyy")
                  .format(DateTime.parse(value))
                  .toString() : '';
              break;
          }
        }
      }
    });
  }

  Widget _createBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ordenar por:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _fieldOrder,
              items: _fieldsToOrder.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: _changeOrder,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _ascending,
                  onChanged: (bool? value) => _changeAscending(value),
                ),
                const Text(
                  'Usar ordem Ascendente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            const Divider(),
            const Text('Filtrar por:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            TextFormField(
              controller: nameFilterController,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
              onChanged: (value) => _changeFilters(),
            ),
            TextFormField(
              controller: descriptionFilterController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              onChanged: (value) => _changeFilters(),
            ),
            TextFormField(
              controller: differentialsFilterController,
              decoration: const InputDecoration(
                labelText: 'Diferenciais',
              ),
              onChanged: (value) => _changeFilters(),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _savePreferences();
                    Navigator.pop(context, _changeValues);
                  }
                },
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
      _changeFilters();
      setState(() {
        createdAtFilterController.text =
            DateFormat("dd/MM/yyyy").format(newDate);
      });
    }
  }

  void _savePreferences() {
    if (_changeValues) {
      _preferences.setString(
          AttractionFilters.keyFieldOrder, _fieldOrder.toString());
      _preferences.setBool(AttractionFilters.keyAscending, _ascending);

      final isoDate = createdAtFilterController.text.isNotEmpty
          ? DateFormat("dd/MM/yyyy")
              .parse(createdAtFilterController.text)
              .toIso8601String()
          : '';

      final filters = {
        Attraction.FIELD_NAME: nameFilterController.text,
        Attraction.FIELD_DESCRIPTION: descriptionFilterController.text,
        Attraction.FIELD_DIFFERENTIALS: differentialsFilterController.text,
        Attraction.FIELD_CREATED_AT: isoDate.split('T')[0],
      };
      final filtersString =
          filters.entries.map((e) => '${e.key}:${e.value}').toList().join('|');
      _preferences.setString(AttractionFilters.keyFilters, filtersString);
    }
  }

  void _changeOrder(String? value) {
    setState(() {
      _fieldOrder = value ?? Attraction.FIELD_NAME;
      _changeValues = true;
    });
  }

  void _changeAscending(bool? value) {
    setState(() {
      _ascending = value ?? true;
      _changeValues = true;
    });
  }

  void _changeFilters() {
    setState(() {
      _changeValues = true;
    });
  }
}
