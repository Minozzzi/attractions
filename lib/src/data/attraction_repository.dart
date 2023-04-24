import 'package:attractions/src/database/db_provider.dart';
import 'package:attractions/src/domain/attraction.dart';
import 'package:sqflite/sqflite.dart';

class AttractionRepository {
  final dbProvider = DatabaseProvider.instance;

  Future<List<Attraction>> getAttractions({
    String filters = '',
    String fieldOrderBy  = Attraction.FIELD_ID,
    bool ascending = true,
  }) async {
    final database = await dbProvider.database;
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
    final database = await dbProvider.database;
    final values = attraction.toJson();
    values.remove(Attraction.FIELD_ID);
    final id = await database.insert(Attraction.TABLE_NAME, values);
    attraction.id = id;
  }

  Future<void> updateAttraction(Attraction attraction) async {
    final database = await dbProvider.database;
    final values = attraction.toJson();
    values.remove(Attraction.FIELD_ID);
    values.remove(Attraction.FIELD_CREATED_AT);
    await database.update(Attraction.TABLE_NAME, values,
        where: '${Attraction.FIELD_ID} = ?', whereArgs: [attraction.id]);
  }

  Future<void> removeAttraction(Attraction attraction) async {
    final database = await dbProvider.database;
    await database.delete(Attraction.TABLE_NAME,
        where: '${Attraction.FIELD_ID} = ?', whereArgs: [attraction.id]);
  }
}
