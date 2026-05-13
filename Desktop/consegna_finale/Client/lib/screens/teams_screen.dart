import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import 'players_screen.dart';
import 'favorites_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<Team> _teams = [];
  Set<int> _favIds = {};
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final teams  = await ApiService.getTeams();
      final favIds = await DbService.getFavoriteTeamIds();
      for (final t in teams) t.isFavorite = favIds.contains(t.id);
      setState(() { _teams = teams; _favIds = favIds.toSet(); });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFav(Team t) async {
    if (t.isFavorite) {
      await DbService.removeTeam(t.id);
      _favIds.remove(t.id);
    } else {
      await DbService.addTeam(t);
      _favIds.add(t.id);
    }
    setState(() => t.isFavorite = !t.isFavorite);
    _showSnack(t.isFavorite ? '★ ${t.name} aggiunta ai preferiti' : '${t.name} rimossa', t.isFavorite);
  }

  void _showSnack(String msg, bool ok) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? const Color(0xFF00D4AA) : Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161921),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            children: [
              TextSpan(text: 'CALCIO ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'DB', style: TextStyle(color: Color(0xFF00D4AA))),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rounded, color: Color(0xFFF5A623)),
            tooltip: 'Preferiti',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text('Errore di connessione', style: TextStyle(color: Colors.red[300], fontSize: 16)),
          const SizedBox(height: 6),
          Text(_error!, style: const TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), foregroundColor: Colors.black),
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Riprova'),
          ),
        ]),
      );
    }
    if (_teams.isEmpty) {
      return const Center(child: Text('Nessuna squadra', style: TextStyle(color: Colors.white54)));
    }

    return RefreshIndicator(
      color: const Color(0xFF00D4AA),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _teams.length,
        itemBuilder: (_, i) => _TeamTile(
          team: _teams[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayersScreen(team: _teams[i])),
          ),
          onFav: () => _toggleFav(_teams[i]),
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final Team team;
  final VoidCallback onTap;
  final VoidCallback onFav;

  const _TeamTile({required this.team, required this.onTap, required this.onFav});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${team.position}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Image.network(
              team.logo,
              width: 32, height: 32,
              errorBuilder: (_, __, ___) => Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: const Color(0xFF1E2230), borderRadius: BorderRadius.circular(4)),
                child: Center(child: Text(team.name.substring(0, 1), style: const TextStyle(color: Colors.white38, fontSize: 14))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(team.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            IconButton(
              icon: Icon(
                team.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: team.isFavorite ? const Color(0xFFF5A623) : Colors.white30,
              ),
              onPressed: onFav,
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
