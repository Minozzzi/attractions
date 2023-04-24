import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionListService {
  final AttractionRepository _attractionRepository;

  AttractionListService(this._attractionRepository);

  Future<List<Attraction>> getAttractionList({
    String filters = '',
    String fieldOrderBy = Attraction.FIELD_NAME,
    bool ascending = true,
  }) async {
    final filtersJson = filters.split('|');
    final filtersMap = <String, dynamic>{};

    for (final filter in filtersJson) {
      final filterParts = filter.split(':');

      if (filterParts.length == 2) {
        final key = filterParts[0];
        final value = filterParts[1];
        filtersMap[key] = value;
      }
    }

    return await _attractionRepository.getAttractions(
      filters: filtersMap,
      fieldOrderBy: fieldOrderBy,
      ascending: ascending,
    );
  }
}
