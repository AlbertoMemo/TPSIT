import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';

class PlayersScreen extends StatefulWidget {
  final Team team;
  const PlayersScreen({super.key, required this.team});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  Map<String, List<Player>> _groups = {};
  Set<int> _favIds = {};
  bool _loading = false;
  String? _error;

  static const _groupLabels = {
    'keepers': 'Portieri',
    'defenders': 'Difensori',
    'midfielders': 'Centrocampisti',
    'attackers': 'Attaccanti',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final groups = await ApiService.getPlayers(widget.team.id);
      final favIds = await DbService.getFavoritePlayerIds();
      for (final players in groups.values) {
        for (final p in players) p.isFavorite = favIds.contains(p.id);
      }
      setState(() { _groups = groups; _favIds = favIds.toSet(); });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFav(Player p) async {
    if (p.isFavorite) {
      await DbService.removePlayer(p.id);
      _favIds.remove(p.id);
    } else {
      await DbService.addPlayer(p);
      _favIds.add(p.id);
    }
    setState(() => p.isFavorite = !p.isFavorite);
    _showSnack(p.isFavorite ? '★ ${p.name} aggiunto ai preferiti' : '${p.name} rimosso', p.isFavorite);
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
        leading: const BackButton(color: Colors.white70),
        title: Row(
          children: [
            Image.network(widget.team.logo, width: 28, height: 28,
                errorBuilder: (_, __, ___) => const SizedBox(width: 28)),
            const SizedBox(width: 10),
            Text(widget.team.name,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));

    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text('Errore: $_error', style: const TextStyle(color: Colors.red, fontSize: 13)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _load, child: const Text('Riprova')),
      ]));
    }

    if (_groups.isEmpty) return const Center(child: Text('Nessun giocatore', style: TextStyle(color: Colors.white54)));

    // costruiamo la lista con header di gruppo + card grid
    final items = <Widget>[];
    _groupLabels.forEach((key, label) {
      final players = _groups[key];
      if (players == null || players.isEmpty) return;
      items.add(_GroupHeader(label: label));
      items.add(_PlayersGrid(players: players, onFav: _toggleFav));
    });

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: items);
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12,
                fontWeight: FontWeight.w600, letterSpacing: 1.4)),
        const SizedBox(height: 6),
        Container(height: 1, color: Colors.white.withOpacity(0.07)),
      ]),
    );
  }
}

class _PlayersGrid extends StatelessWidget {
  final List<Player> players;
  final Future<void> Function(Player) onFav;

  const _PlayersGrid({required this.players, required this.onFav});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: players.length,
        itemBuilder: (_, i) => _PlayerCard(player: players[i], onFav: onFav),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  final Future<void> Function(Player) onFav;

  const _PlayerCard({required this.player, required this.onFav});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161921),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: player.isFavorite
              ? const Color(0xFFF5A623).withOpacity(0.5)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // avatar con iniziali
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2230),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(player.initials,
                        style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                // nome
                Text(
                  player.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // ruolo
                Text(
                  player.role,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                if (player.injured) ...[
                  const SizedBox(height: 4),
                  const Text('⚕ Infort.', style: TextStyle(color: Colors.redAccent, fontSize: 9)),
                ],
              ],
            ),
          ),
          // numero maglia
          if (player.shirtNumber > 0)
            Positioned(
              top: 6, left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('#${player.shirtNumber}',
                    style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
          // stella preferiti
          Positioned(
            top: 2, right: 2,
            child: GestureDetector(
              onTap: () => onFav(player),
              child: Icon(
                player.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: player.isFavorite ? const Color(0xFFF5A623) : Colors.white24,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
