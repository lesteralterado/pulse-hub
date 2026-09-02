import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/application/profile_providers.dart';
import '../../../profile/domain/user_profile.dart';

/// Search-by-username, multi-select picker. Pops with the selected
/// [UserProfile]s (or null if cancelled). Shared by "new conversation"
/// (1 selection = direct chat, 2+ = prompts for a group name) and
/// "add group member" (each selection gets added).
class UserPickerPage extends ConsumerStatefulWidget {
  const UserPickerPage({super.key, this.excludeUserIds = const {}});

  final Set<String> excludeUserIds;

  @override
  ConsumerState<UserPickerPage> createState() => _UserPickerPageState();
}

class _UserPickerPageState extends ConsumerState<UserPickerPage> {
  final _searchController = TextEditingController();
  List<UserProfile> _results = [];
  final Map<String, UserProfile> _selected = {};
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);
    final result = await ref.read(profileRepositoryProvider).searchProfiles(trimmed);
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _results = result.when(
        success: (profiles) =>
            profiles.where((p) => !widget.excludeUserIds.contains(p.id)).toList(),
        failure: (_) => const [],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find people'),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selected.values.toList()),
              child: Text('Done (${_selected.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final profile = _results[index];
                      final isSelected = _selected.containsKey(profile.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _selected[profile.id] = profile;
                            } else {
                              _selected.remove(profile.id);
                            }
                          });
                        },
                        title: Text(profile.displayName ?? profile.username ?? 'Unknown'),
                        subtitle:
                            profile.username != null ? Text('@${profile.username}') : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
