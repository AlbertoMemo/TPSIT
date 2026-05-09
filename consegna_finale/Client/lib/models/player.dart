class Player {
  final int id;
  final String name;
  final int shirtNumber;
  final String role;
  final String groupTitle;
  final int teamId;
  final bool injured;
  final String? expectedReturn;
  bool isFavorite;

  Player({
    required this.id,
    required this.name,
    required this.shirtNumber,
    required this.role,
    required this.groupTitle,
    required this.teamId,
    this.injured = false,
    this.expectedReturn,
    this.isFavorite = false,
  });

  factory Player.fromJson(Map<String, dynamic> j, String group, int teamId) => Player(
        id: j['id'],
        name: j['name'] ?? '',
        shirtNumber: j['shirtNumber'] ?? 0,
        role: j['role']?['fallback'] ?? '',
        groupTitle: group,
        teamId: teamId,
        injured: j['injured'] == true,
        expectedReturn: j['injury']?['expectedReturn'],
      );

  // initials
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
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
        'player_id': id,
        'nome': firstName,
        'cognome': lastName,
        'numero_maglia': shirtNumber,
        'squadra_id': teamId,
      };
}
