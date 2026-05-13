class Team {
  final int id;
  final String name;
  final String logo;
  final int position;
  bool isFavorite;

  Team({
    required this.id,
    required this.name,
    required this.logo,
    required this.position,
    this.isFavorite = false,
  });

  factory Team.fromJson(Map<String, dynamic> j, int idx) => Team(
        id: j['id'],
        name: j['name'] ?? '',
        logo: j['logo'] ?? '',
        position: j['idx'] ?? idx,
      );

  Map<String, dynamic> toDb() => {'team_id': id, 'nome_squadra': name, 'logo': logo};
}
