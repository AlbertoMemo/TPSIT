import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/team.dart';
import '../models/player.dart';

class DbService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'calcio.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE squadre_preferite (
            team_id     INTEGER PRIMARY KEY,
            nome_squadra TEXT NOT NULL,
            logo        TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE giocatori_preferiti (
            player_id     INTEGER PRIMARY KEY,
            nome          TEXT NOT NULL,
            cognome       TEXT NOT NULL,
            numero_maglia INTEGER DEFAULT 0,
            squadra_id    INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /* ---- SQUADRE ---- */

  static Future<List<int>> getFavoriteTeamIds() async {
    final res = await (await db).query('squadre_preferite', columns: ['team_id']);
    return res.map((r) => r['team_id'] as int).toList();
  }

  static Future<List<Map<String, dynamic>>> getFavoriteTeams() async {
    return (await db).query('squadre_preferite', orderBy: 'nome_squadra ASC');
  }

  static Future<void> addTeam(Team t) async {
    await (await db).insert(
      'squadre_preferite',
      t.toDb(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> removeTeam(int teamId) async {
    await (await db).delete('squadre_preferite', where: 'team_id = ?', whereArgs: [teamId]);
  }

  /* ---- GIOCATORI ---- */

  static Future<List<int>> getFavoritePlayerIds() async {
    final res = await (await db).query('giocatori_preferiti', columns: ['player_id']);
    return res.map((r) => r['player_id'] as int).toList();
  }

  static Future<List<Map<String, dynamic>>> getFavoritePlayers() async {
    return (await db).query('giocatori_preferiti', orderBy: 'nome ASC');
  }

  static Future<void> addPlayer(Player p) async {
    await (await db).insert(
      'giocatori_preferiti',
      p.toDb(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> removePlayer(int playerId) async {
    await (await db).delete('giocatori_preferiti', where: 'player_id = ?', whereArgs: [playerId]);
  }
}
