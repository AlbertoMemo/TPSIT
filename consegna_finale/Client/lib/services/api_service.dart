import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/player.dart';
import 'db_service.dart';

class ApiService {
  // cambia IP se usi dispositivo fisico sulla stessa rete
  static const String base =
      'http://192.168.0.253/php/consegna_finale/Server/index.php';




  static Future<List<Team>> getTeams() async {
    try {
      final res = await http.get(Uri.parse('$base?action=get_teams'));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final data = jsonDecode(res.body);
      final list = data['response']['list'] as List;
      final teams = list.asMap().entries
          .map((e) => Team.fromJson(e.value, e.key + 1))
          .toList();

      // Salva in cache dopo un successo
      await DbService.saveTeamsCache(teams);

      return teams;
    } catch (_) {
      // Chiamata fallita: prova a leggere dalla cache locale
      final cached = await DbService.loadTeamsCache();
      if (cached != null) {
        return cached;
      }
      // Nessuna cache disponibile: rilancia l'errore
      rethrow;
    }
  }




  static Future<Map<String, List<Player>>> getPlayers(int teamId) async {
    try {
      final res = await http
          .get(Uri.parse('$base?action=get_players&team_id=$teamId'));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final data = jsonDecode(res.body);
      final squad = data['response']['squad'] as List;

      final Map<String, List<Player>> groups = {};
      for (final group in squad) {
        final title = group['title'] as String;
        if (title == 'coach') continue;
        final members = (group['members'] as List)
            .map((p) => Player.fromJson(p, title, teamId))
            .toList();
        if (members.isNotEmpty) groups[title] = members;
      }


      await DbService.savePlayersCache(teamId, groups);

      return groups;
    } catch (_) {
      final cached = await DbService.loadPlayersCache(teamId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }
}