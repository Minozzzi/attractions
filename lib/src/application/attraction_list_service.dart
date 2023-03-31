import 'package:attractions/src/data/attraction_repository.dart';
import 'package:attractions/src/domain/attraction.dart';

class AttractionListService {
  final AttractionRepository _attractionRepository;

  AttractionListService(this._attractionRepository);

  Future<List<Attraction>> getAttractionList() async {
    return await _attractionRepository.getAttractions();
  }

  Future<Attraction> getOneAttraction(int id) async {
    return await _attractionRepository.getOneAttraction(id);
  }  
}
