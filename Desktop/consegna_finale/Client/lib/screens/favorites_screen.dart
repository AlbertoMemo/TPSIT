import 'package:flutter/material.dart';
import '../services/db_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _teams = [];
  List<Map<String, dynamic>> _players = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final teams   = await DbService.getFavoriteTeams();
    final players = await DbService.getFavoritePlayers();
    setState(() { _teams = teams; _players = players; });
  }

  Future<void> _removeTeam(int teamId) async {
    await DbService.removeTeam(teamId);
    _load();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Squadra rimossa dai preferiti'),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _removePlayer(int playerId) async {
    await DbService.removePlayer(playerId);
    _load();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Giocatore rimosso dai preferiti'),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161921),
        leading: const BackButton(color: Colors.white70),
        title: const Text('Preferiti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF00D4AA),
          labelColor: const Color(0xFF00D4AA),
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: 'SQUADRE (${_teams.length})'),
            Tab(text: 'GIOCATORI (${_players.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildTeamsList(),
          _buildPlayersList(),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
    if (_teams.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star_border_rounded, color: Colors.white24, size: 56),
          SizedBox(height: 12),
          Text('Nessuna squadra preferita', style: TextStyle(color: Colors.white38, fontSize: 15)),
          SizedBox(height: 6),
          Text('Premi ★ su una squadra per salvarla', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _teams.length,
      itemBuilder: (_, i) {
        final t = _teams[i];
        return Dismissible(
          key: Key('team_${t['team_id']}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red.withOpacity(0.7),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _removeTeam(t['team_id'] as int),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield, color: Color(0xFF00D4AA), size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(t['nome_squadra'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 15)),
                ),
                GestureDetector(
                  onTap: () => _removeTeam(t['team_id'] as int),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 22),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayersList() {
    if (_players.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_outline, color: Colors.white24, size: 56),
          SizedBox(height: 12),
          Text('Nessun giocatore preferito', style: TextStyle(color: Colors.white38, fontSize: 15)),
          SizedBox(height: 6),
          Text('Premi ★ su un giocatore per salvarlo', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _players.length,
      itemBuilder: (_, i) {
        final p = _players[i];
        final nome    = p['nome'] as String? ?? '';
        final cognome = p['cognome'] as String? ?? '';
        final numero  = p['numero_maglia'] as int? ?? 0;
        final nomeCompleto = '$nome $cognome'.trim();
        final iniziali = ((nome.isNotEmpty ? nome[0] : '') + (cognome.isNotEmpty ? cognome[0] : '')).toUpperCase();

        return Dismissible(
          key: Key('player_${p['player_id']}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red.withOpacity(0.7),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _removePlayer(p['player_id'] as int),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2230),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(iniziali,
                        style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(nomeCompleto, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    if (numero > 0)
                      Text('#$numero', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ]),
                ),
                GestureDetector(
                  onTap: () => _removePlayer(p['player_id'] as int),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 22),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
