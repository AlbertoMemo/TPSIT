class Player {
  final int id;
  final String name;
  final int shirtNumber;
  final String role;
  final String groupTitle;
  final int teamId;
  final bool injured;
  final int age;
  final int goals;
  final int assists;
  bool isFavorite;

  Player({
    required this.id,
    required this.name,
    required this.shirtNumber,
    required this.role,
    required this.groupTitle,
    required this.teamId,
    this.injured = false,
    this.age = 0,
    this.goals = 0,
    this.assists = 0,
    this.isFavorite = false,
  });

  factory Player.fromJson(Map<String, dynamic> j, String group, int teamId) => Player(
        id:          j['id'],
        name:        j['name'] ?? '',
        shirtNumber: j['shirtNumber'] ?? 0,
        role:        j['role']?['fallback'] ?? '',
        groupTitle:  group,
        teamId:      teamId,
        injured:     j['injured'] == true,
        age:         j['age'] ?? 0,
        goals:       j['goals'] ?? 0,
        assists:     j['assists'] ?? 0,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first;
  }

  String get lastName {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  Map<String, dynamic> toDb() => {
        'player_id':     id,
        'nome':          firstName,
        'cognome':       lastName,
        'numero_maglia': shirtNumber,
        'squadra_id':    teamId,
      };
}