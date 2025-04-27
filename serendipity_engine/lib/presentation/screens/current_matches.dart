import 'package:flutter/material.dart';
import 'package:serendipity_engine/services/api_service.dart';
import 'dart:convert';

class CurrentMatches extends StatefulWidget {
  const CurrentMatches({super.key});

  @override
  State<CurrentMatches> createState() => _CurrentMatchesState();
}

class _CurrentMatchesState extends State<CurrentMatches> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _pendingConnections = [];
  List<dynamic> _suggestedConnections = [];

  @override
  void initState() {
    super.initState();
    _loadPendingConnections();
    _loadSuggestedConnections();
  }

  Future<void> _loadPendingConnections() async {
    try {
      final response = await _apiService.get('connections/pending/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingConnections = data['connections'] ?? [];
          _isLoading = false;
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load pending connections')),
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

  Future<void> _loadSuggestedConnections() async {
    try {
      final response = await _apiService.get('connections/suggested/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestedConnections = data['suggestions'] ?? [];
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptConnection(int userId) async {
    try {
      final response = await _apiService.post('connections/accept/', {
        'user_id': userId,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection accepted')));
        // Refresh the lists
        _loadPendingConnections();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept connection')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _rejectConnection(int userId) async {
    try {
      final response = await _apiService.post('connections/reject/', {
        'user_id': userId,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection rejected')));
        // Refresh the list
        _loadPendingConnections();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to reject connection')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Find People')
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  await _loadPendingConnections();
                  await _loadSuggestedConnections();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPendingConnectionsSection(),
                        const SizedBox(height: 24),
                        //_buildSuggestedConnectionsSection(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildPendingConnectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _pendingConnections.isEmpty
            ? const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No nearby connections',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingConnections.length,
              itemBuilder: (context, index) {
                final connection = _pendingConnections[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          connection['profile_image'] != null
                              ? NetworkImage(connection['profile_image'])
                              : null,
                      child:
                          connection['profile_image'] == null
                              ? Text(connection['name'][0])
                              : null,
                    ),
                    title: Text(connection['name'] ?? 'User'),
                    subtitle: Text(
                      connection['bio'] ?? 'No bio available',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptConnection(connection['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectConnection(connection['id']),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Show user profile details
                      // This would be implemented separately
                    },
                  ),
                );
              },
            ),
      ],
    );
  }
}