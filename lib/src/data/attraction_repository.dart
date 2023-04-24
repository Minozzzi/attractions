import 'package:attractions/src/database/db_provider.dart';
import 'package:attractions/src/domain/attraction.dart';
import 'package:sqflite/sqflite.dart';

class AttractionRepository {
  final dbProvider = DatabaseProvider.instance;

  late Database database;

  AttractionRepository() {
    _init();
  }

  Future<void> _init() async {
    database = await dbProvider.database;
  }

  Future<List<Attraction>> getAttractions({
    String filters = '',
    String fieldOrderBy  = Attraction.FIELD_ID,
    bool ascending = true,
  }) async {
    String? where;

    if (filters.isNotEmpty) {
      where = "UPPER(${Attraction.FIELD_NAME}) LIKE UPPER('%$filters%')";
    }

    final orderBy = '$fieldOrderBy ${ascending ? 'ASC' : 'DESC'}';

    final attractions = await database.query(
      Attraction.TABLE_NAME,
      where: where,
      orderBy: orderBy,
    );

    return attractions.map((attraction) => Attraction.fromJson(attraction)).toList();

  }

  Future<void> addAttraction(Attraction attraction) async {
    final values = attraction.toJson();
    values.remove(Attraction.FIELD_ID);
    final id = await database.insert(Attraction.TABLE_NAME, values);
    attraction.id = id;
  }

  Future<void> updateAttraction(Attraction attraction) async {
    final values = attraction.toJson();
    values.remove(Attraction.FIELD_ID);
    await database.update(Attraction.TABLE_NAME, values,
        where: '${Attraction.FIELD_ID} = ?', whereArgs: [attraction.id]);
  }

  Future<void> removeAttraction(Attraction attraction) async {
    await database.delete(Attraction.TABLE_NAME,
        where: '${Attraction.FIELD_ID} = ?', whereArgs: [attraction.id]);
  }
}
