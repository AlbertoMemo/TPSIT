import 'dart:convert';
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
      version: 2, // incrementata per aggiungere le tabelle di cache
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Aggiunge le tabelle di cache se si aggiorna dalla v1
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cache_teams (
              cache_key   TEXT PRIMARY KEY,
              json_data   TEXT NOT NULL,
              updated_at  INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cache_players (
              cache_key   TEXT PRIMARY KEY,
              json_data   TEXT NOT NULL,
              updated_at  INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
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
    await db.execute('''
      CREATE TABLE cache_teams (
        cache_key   TEXT PRIMARY KEY,
        json_data   TEXT NOT NULL,
        updated_at  INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE cache_players (
        cache_key   TEXT PRIMARY KEY,
        json_data   TEXT NOT NULL,
        updated_at  INTEGER NOT NULL
      )
    ''');
  }



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










  static Future<void> saveTeamsCache(List<Team> teams) async {
    final jsonData = jsonEncode(teams.map((t) => {
      'id':       t.id,
      'name':     t.name,
      'logo':     t.logo,
      'position': t.position,
    }).toList());

    await (await db).insert(
      'cache_teams',
      {
        'cache_key':  'teams',
        'json_data':  jsonData,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }




  static Future<List<Team>?> loadTeamsCache() async {
    final rows = await (await db).query(
      'cache_teams',
      where: 'cache_key = ?',
      whereArgs: ['teams'],
    );
    if (rows.isEmpty) return null;

    final list = jsonDecode(rows.first['json_data'] as String) as List;
    return list.asMap().entries
        .map((e) => Team.fromJson(Map<String, dynamic>.from(e.value), e.key + 1))
        .toList();
  }








  static Future<void> savePlayersCache(
      int teamId, Map<String, List<Player>> groups) async {
    final jsonData = jsonEncode(
      groups.map((title, players) => MapEntry(
        title,
        players.map((p) => {
          'id':          p.id,
          'name':        p.name,
          'shirtNumber': p.shirtNumber,
          'role':        p.role,
          'groupTitle':  p.groupTitle,
          'teamId':      p.teamId,
          'injured':     p.injured,
          'age':         p.age,
          'goals':       p.goals,
          'assists':     p.assists,
        }).toList(),
      )),
    );

    await (await db).insert(
      'cache_players',
      {
        'cache_key':  'players_$teamId',
        'json_data':  jsonData,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }




  static Future<Map<String, List<Player>>?> loadPlayersCache(int teamId) async {
    final rows = await (await db).query(
      'cache_players',
      where: 'cache_key = ?',
      whereArgs: ['players_$teamId'],
    );
    if (rows.isEmpty) return null;

    final raw = jsonDecode(rows.first['json_data'] as String) as Map<String, dynamic>;
    return raw.map((title, playerList) => MapEntry(
      title,
      (playerList as List).map((p) {
        final map = Map<String, dynamic>.from(p);
        return Player(
          id:          map['id'],
          name:        map['name'] ?? '',
          shirtNumber: map['shirtNumber'] ?? 0,
          role:        map['role'] ?? '',
          groupTitle:  map['groupTitle'] ?? '',
          teamId:      map['teamId'],
          injured:     map['injured'] == true,
          age:         map['age'] ?? 0,
          goals:       map['goals'] ?? 0,
          assists:     map['assists'] ?? 0,
        );
      }).toList(),
    ));
  }
}