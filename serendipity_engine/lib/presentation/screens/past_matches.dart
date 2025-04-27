import 'package:flutter/material.dart';
import 'package:serendipity_engine/services/api_service.dart';
import 'dart:convert';

class PastMatches extends StatefulWidget {
  const PastMatches({super.key});

  @override
  State<PastMatches> createState() => _PastMatchesState();
}

class _PastMatchesState extends State<PastMatches> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _connections = [];

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.get('connections/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _connections = data['connections'] ?? [];

          // Sort connections by most recent first
          _connections.sort((a, b) {
            final DateTime dateA = DateTime.parse(a['connected_date']);
            final DateTime dateB = DateTime.parse(b['connected_date']);
            return dateB.compareTo(dateA); // Descending order (newest first)
          });

          _isLoading = false;
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load connections')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Error: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeConnection(int userId) async {
    try {
      final response = await _apiService.delete('connections/$userId/');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection removed')));
        // Refresh the list
        _loadConnections();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove connection')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Error: ${e.toString()}');
    }
  }

  String _formatConnectionDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Today
      return 'Today';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Days ago
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      // Weeks ago
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      // Format as date
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Connections')
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadConnections,
                child:
                    _connections.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No connections yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to Find People tab
                                  if (context.mounted) {
                                    // This assumes you have a way to communicate with the parent Home widget
                                    // to switch to the Find People tab (index 0)
                                    // For simplicity, you could use a global key or state management solution
                                  }
                                },
                                child: const Text('Find People'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _connections.length,
                          itemBuilder: (context, index) {
                            final connection = _connections[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      connection['profile_image'] != null
                                          ? NetworkImage(
                                            connection['profile_image'],
                                          )
                                          : null,
                                  child:
                                      connection['profile_image'] == null
                                          ? Text(connection['name'][0])
                                          : null,
                                ),
                                title: Text(connection['name'] ?? 'User'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      connection['major'] ??
                                          'No major specified',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Connected: ${_formatConnectionDate(connection['connected_date'])}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder:
                                          (context) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.message,
                                                ),
                                                title: const Text('Message'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  // Implement navigation to messaging
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.person,
                                                ),
                                                title: const Text(
                                                  'View Profile',
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  // Implement navigation to profile view
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.person_remove,
                                                  color: Colors.red,
                                                ),
                                                title: const Text(
                                                  'Remove Connection',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _showRemoveConnectionDialog(
                                                    connection['id'],
                                                    connection['name'],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                                onTap: () {
                                  // View connection profile
                                  // Implement navigation to profile view
                                },
                              ),
                            );
                          },
                        ),
              ),
    );
  }

  void _showRemoveConnectionDialog(int userId, String userName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Connection'),
            content: Text(
              'Are you sure you want to remove $userName from your connections?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _removeConnection(userId);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
