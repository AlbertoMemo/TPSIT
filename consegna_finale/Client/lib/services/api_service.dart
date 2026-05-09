import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/player.dart';

class ApiService {
  // cambia con il tuo IP se testi su dispositivo fisico
  static const String base = 'http://192.168.0.45/php/consegna_finale/Server/index.php';

  static Future<List<Team>> getTeams() async {
    final res = await http.get(Uri.parse('$base?action=get_teams'));
    final data = jsonDecode(res.body);
    final list = (data['response']['list'] as List);
    return list.asMap().entries.map((e) => Team.fromJson(e.value, e.key + 1)).toList();
  }

  static Future<Map<String, List<Player>>> getPlayers(int teamId) async {
    final res = await http.get(Uri.parse('$base?action=get_players&team_id=$teamId'));
    final data = jsonDecode(res.body);
    final squad = data['response']['list']['squad'] as List;

    final Map<String, List<Player>> groups = {};
    for (final group in squad) {
      final title = group['title'] as String;
      if (title == 'coach') continue;
      final members = (group['members'] as List)
          .map((p) => Player.fromJson(p, title, teamId))
          .toList();
      if (members.isNotEmpty) groups[title] = members;
    }
    return groups;
  }
}
