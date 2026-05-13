import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    'keepers':     'Portieri',
    'defenders':   'Difensori',
    'midfielders': 'Centrocampisti',
    'attackers':   'Attaccanti',
  };

  static const _groupOrder = ['keepers', 'defenders', 'midfielders', 'attackers'];

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
    _snack(p.isFavorite ? '★ ${p.name} aggiunto ai preferiti' : '${p.name} rimosso', p.isFavorite);
  }


  Future<void> _delete(Player p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2230),
        title: const Text('Elimina giocatore', style: TextStyle(color: Colors.white)),
        content: Text('Vuoi eliminare ${p.name}?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final res = await http.delete(Uri.parse('${ApiService.base}?action=player&id=${p.id}'));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _snack('${p.name} eliminato', false);
        _load();
      } else {
        _snack('Errore: ${data['message']}', false);
      }
    } catch (_) {
      _snack('Errore di connessione', false);
    }
  }


  Future<void> _edit(Player p) async {
    final result = await _showForm(p);
    if (result == null) return;

    try {
      final res = await http.put(
        Uri.parse('${ApiService.base}?action=player'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({...result, 'id': p.id}),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _snack('${result['name']} modificato ✓', true);
        _load();
      } else {
        _snack('Errore: ${data['message']}', false);
      }
    } catch (_) {
      _snack('Errore di connessione', false);
    }
  }


  Future<void> _add() async {
    final result = await _showForm(null);
    if (result == null) return;

    try {
      final res = await http.post(
        Uri.parse('${ApiService.base}?action=player'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({...result, 'team_id': widget.team.id}),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        _snack('${result['name']} aggiunto ✓', true);
        _load();
      } else {
        _snack('Errore: ${data['message']}', false);
      }
    } catch (e) {
      _snack('Errore: $e', false);
    }
  }

 
  Future<Map<String, dynamic>?> _showForm(Player? p) {
  final nameCtrl   = TextEditingController(text: p?.name ?? '');
  final ageCtrl    = TextEditingController(text: p != null ? p.age.toString() : '');
  final shirtCtrl  = TextEditingController(text: p != null && p.shirtNumber > 0 ? p.shirtNumber.toString() : '');
  final goalsCtrl  = TextEditingController(text: p?.goals.toString() ?? '0');
  final assistCtrl = TextEditingController(text: p?.assists.toString() ?? '0');
  String roleTitle = p?.groupTitle ?? 'attackers';

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        backgroundColor: const Color(0xFF161921),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          p != null ? 'Modifica ${p.name}' : 'Aggiungi giocatore',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _tf('Nome', nameCtrl),
            _tf('Età', ageCtrl, kb: TextInputType.number),
            _tf('Numero maglia', shirtCtrl, kb: TextInputType.number),
            _tf('Goal', goalsCtrl, kb: TextInputType.number),
            _tf('Assist', assistCtrl, kb: TextInputType.number),
            const SizedBox(height: 8),
            // Ruolo
            DropdownButtonFormField<String>(
              value: roleTitle,
              dropdownColor: const Color(0xFF1E2230),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Ruolo',
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E2230),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: const [
                DropdownMenuItem(value: 'keepers',     child: Text('Portiere')),
                DropdownMenuItem(value: 'defenders',   child: Text('Difensore')),
                DropdownMenuItem(value: 'midfielders', child: Text('Centrocampista')),
                DropdownMenuItem(value: 'attackers',   child: Text('Attaccante')),
              ],
              onChanged: (v) => setS(() => roleTitle = v!),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              // mappa ruolo → key e fallback
              final roleMap = {
                'keepers':     {'key': 'keeper_long',    'fallback': 'Keeper'},
                'defenders':   {'key': 'defender_long',  'fallback': 'Defender'},
                'midfielders': {'key': 'midfielder_long','fallback': 'Midfielder'},
                'attackers':   {'key': 'attacker_long',  'fallback': 'Attacker'},
              };
              Navigator.pop(ctx, {
                'name':         nameCtrl.text.trim(),
                'age':          int.tryParse(ageCtrl.text) ?? 0,
                'shirtNumber':  int.tryParse(shirtCtrl.text) ?? 0,
                'goals':        int.tryParse(goalsCtrl.text) ?? 0,
                'assists':      int.tryParse(assistCtrl.text) ?? 0,
                'role_title':   roleTitle,
                'role_key':     roleMap[roleTitle]!['key'],
                'role_fallback':roleMap[roleTitle]!['fallback'],
              });
            },
            child: Text(p != null ? 'Salva' : 'Aggiungi'),
          ),
        ],
      ),
    ),
  );
  }

  Widget _tf(String label, TextEditingController ctrl, {TextInputType? kb}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: kb,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF1E2230),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void _snack(String msg, bool ok) {
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
        title: Row(children: [
          Image.network(widget.team.logo, width: 28, height: 28,
              errorBuilder: (_, __, ___) => const SizedBox(width: 28)),
          const SizedBox(width: 10),
          Text(widget.team.name,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: Color(0xFF00D4AA)),
            tooltip: 'Aggiungi giocatore',
            onPressed: _add,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, color: Colors.red, size: 48),
      const SizedBox(height: 12),
      Text('Errore: $_error', style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load, child: const Text('Riprova')),
    ]));
    if (_groups.isEmpty) return const Center(
        child: Text('Nessun giocatore', style: TextStyle(color: Colors.white54)));

    final items = <Widget>[];
    for (final key in _groupOrder) {
      final players = _groups[key];
      if (players == null || players.isEmpty) continue;
      items.add(_GroupHeader(label: _groupLabels[key] ?? key));
      items.add(_PlayersGrid(
        players: players,
        onFav: _toggleFav,
        onEdit: _edit,
        onDelete: _delete,
      ));
    }

    return RefreshIndicator(
      color: const Color(0xFF00D4AA),
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: items),
    );
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

/* =================== GRIGLIA =================== */

class _PlayersGrid extends StatelessWidget {
  final List<Player> players;
  final Future<void> Function(Player) onFav;
  final Future<void> Function(Player) onEdit;
  final Future<void> Function(Player) onDelete;

  const _PlayersGrid({required this.players, required this.onFav, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.62,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: players.length,
        itemBuilder: (_, i) => _PlayerCard(
          player: players[i],
          onFav: onFav,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}



class _PlayerCard extends StatelessWidget {
  final Player player;
  final Future<void> Function(Player) onFav;
  final Future<void> Function(Player) onEdit;
  final Future<void> Function(Player) onDelete;

  const _PlayerCard({required this.player, required this.onFav, required this.onEdit, required this.onDelete});

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
      child: Stack(children: [
  
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2230),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00D4AA).withOpacity(0.3)),
              ),
              child: Center(
                child: Text(player.initials,
                    style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 6),
            Text(player.name,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(player.role,
                style: const TextStyle(color: Colors.white38, fontSize: 9),
                textAlign: TextAlign.center),
            if (player.injured)
              const Padding(padding: EdgeInsets.only(top: 3), child: Text('⚕', style: TextStyle(fontSize: 10))),
          ]),
        ),


        if (player.shirtNumber > 0)
          Positioned(
            top: 6, left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF00D4AA),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('#${player.shirtNumber}',
                  style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),


        Positioned(
          top: 4, right: 4,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () => onFav(player),
              child: Icon(
                player.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: player.isFavorite ? const Color(0xFFF5A623) : Colors.white24,
                size: 17,
              ),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () => onEdit(player),
              child: const Icon(Icons.edit_rounded, color: Colors.white38, size: 15),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () => onDelete(player),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 15),
            ),
          ]),
        ),
      ]),
    );
  }
}