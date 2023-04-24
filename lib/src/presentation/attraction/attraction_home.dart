import 'package:attractions/src/application/attraction_create_service.dart';
import 'package:attractions/src/application/attraction_list_service.dart';
import 'package:attractions/src/application/attraction_remove_service.dart';
import 'package:attractions/src/application/attraction_update_service.dart';
import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';
import 'package:attractions/src/presentation/attraction/attraction_modal.dart';
import 'package:attractions/src/presentation/attraction/attraction_list.dart';
import 'package:attractions/src/presentation/attraction/attraction_filter.dart';
import 'package:attractions/src/widget/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttractionHome extends StatefulWidget {
  static final _attractionRepository = AttractionRepository();

  const AttractionHome({super.key});

  @override
  AttractionHomeState createState() => AttractionHomeState();
}

class AttractionHomeState extends State<AttractionHome> {
  Future<List<Attraction>>? _attractionsFuture;

  final _attractionListService =
      AttractionListService(AttractionHome._attractionRepository);

  late final AttractionRemoveService _attractionRemoveService;

  @override
  void initState() {
    super.initState();
    _refreshAttractions();
    _attractionRemoveService = AttractionRemoveService(
        attractionRepository: AttractionHome._attractionRepository,
        onRemoved: onRemoved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _createBody(),
      floatingActionButton:
          FloatingButton(icon: Icons.add, onPressed: addAttraction),
    );
  }

  AppBar _createAppBar() {
    return AppBar(
      title: const Text('Atrações'),
      actions: [
        IconButton(
            onPressed: _openFilters, icon: const Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _createBody() {
    return FutureBuilder<List<Attraction>>(
      future: _attractionsFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<Attraction>> snapshot) =>
              listBuilder(context, snapshot),
    );
  }

  Widget listBuilder(
      BuildContext context, AsyncSnapshot<List<Attraction>> snapshot) {
    final hasDataLength = snapshot.data?.isNotEmpty ?? false;

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasData && hasDataLength) {
      List<Attraction> attractions = snapshot.data!;
      return AttractionList(
          key: UniqueKey(),
          attractions: attractions,
          onSlideRight: _attractionRemoveService.removeAttraction,
          onSlideLeft: updateAttraction,
          onTapCard: onTapCard);
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'Não há atrações cadastradas!',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void onRemoved() {
    setState(() {
      _refreshAttractions();
    });
  }

  void addAttraction() async {
    final newAttraction =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AttractionModal(
        attractionCreateService:
            AttractionCreateService(AttractionHome._attractionRepository),
        attractionUpdateService:
            AttractionUpdateService(AttractionHome._attractionRepository),
        isEditing: false,
        isViewOnly: false,
      );
    }));

    if (newAttraction != null) {
      setState(() {
        _refreshAttractions();
      });
    }
  }

  void updateAttraction(Attraction attraction) async {
    final updatedAttraction =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AttractionModal(
        attractionCreateService:
            AttractionCreateService(AttractionHome._attractionRepository),
        attractionUpdateService:
            AttractionUpdateService(AttractionHome._attractionRepository),
        isEditing: true,
        isViewOnly: false,
        attraction: attraction,
      );
    }));

    if (updatedAttraction != null) {
      setState(() {
        _refreshAttractions();
      });
    }
  }

  void onTapCard(Attraction attraction) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AttractionModal(
        attractionCreateService:
            AttractionCreateService(AttractionHome._attractionRepository),
        attractionUpdateService:
            AttractionUpdateService(AttractionHome._attractionRepository),
        attraction: attraction,
        isViewOnly: true,
        isEditing: false,
      );
    }));
  }

  void _openFilters() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AttractionFilters();
    })).then((changedFilters) => {
          if (changedFilters == true)
            {
              _refreshAttractions()
            }
        });
  }

  void _refreshAttractions() async {
    final prefs = await SharedPreferences.getInstance();

    final fieldOrder = prefs.getString(AttractionFilters.keyFieldOrder) ?? Attraction.FIELD_NAME;
    final asceding = prefs.getBool(AttractionFilters.keyAscending) ?? true;
    final filters = prefs.getString(AttractionFilters.keyFilters) ?? '';

    setState(() {
      _attractionsFuture = _attractionListService.getAttractionList(
          fieldOrderBy: fieldOrder, ascending: asceding, filters: filters);
    });
  }
}
