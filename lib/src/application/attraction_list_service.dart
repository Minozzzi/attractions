import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionListService {
  final AttractionRepository _attractionListRepository;

  AttractionListService(this._attractionListRepository);

  Future<List<Attraction>> getAttractionList() async {
    return await _attractionListRepository.getAttractions();
  }
}
