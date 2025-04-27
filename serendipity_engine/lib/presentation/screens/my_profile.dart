import 'package:flutter/material.dart';
import 'package:serendipity_engine/services/token_service.dart';
import 'package:serendipity_engine/services/api_service.dart';
import 'package:serendipity_engine/presentation/screens/landing_page.dart';
import 'dart:convert';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TokenService _tokenService = TokenService();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _majorController;
  late TextEditingController _minorController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _majorController = TextEditingController();
    _minorController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _minorController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.get('profile/me');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data;
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _majorController.text = data['major'] ?? '';
          _minorController.text = data['minor'] ?? '';
          _isLoading = false;
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        'name': _nameController.text,
        'bio': _bioController.text,
        'major': _majorController.text,
        'minor': _minorController.text,
      };

      final response = await _apiService.put('profile/me', updatedData);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _userData = {..._userData, ...updatedData};
          _isEditing = false;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _tokenService.deleteTokens();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LandingPage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _userData['profile_image'] != null
                              ? NetworkImage(_userData['profile_image'])
                              : null,
                          child: _userData['profile_image'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _isEditing
                            ? Container() // Hide this text in edit mode
                            : Text(
                                _userData['name'] ?? 'User',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isEditing ? _buildEditForm() : _buildProfileInfo(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _updateProfile();
          } else {
            setState(() {
              _isEditing = true;
            });
          }
        },
        child: Icon(_isEditing ? Icons.save : Icons.edit),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection('About Me', _userData['bio'] ?? 'No bio added yet'),
            const Divider(),
            _buildInfoSection('Major', _userData['major'] ?? 'Not specified'),
            const Divider(),
            _buildInfoSection('Minor', _userData['minor'] ?? 'Not specified'),
            const Divider(),
            _buildInfoSection('Email', _userData['email'] ?? 'No email available'),
            if (_userData['personality_results'] != null) ...[
              const Divider(),
              _buildPersonalitySection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildPersonalitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personality Traits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        // This would display personality traits from the test
        // This is a placeholder that you'd adapt based on your actual data structure
        if (_userData['personality_results'] is Map) ...[
          for (var entry in (_userData['personality_results'] as Map).entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key.toString().split('_').map((word) => 
                        word.substring(0, 1).toUpperCase() + word.substring(1)
                      ).join(' '),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: LinearProgressIndicator(
                      value: (entry.value as num).toDouble() / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value}%'),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'About Me',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _majorController,
            decoration: const InputDecoration(
              labelText: 'Major',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _minorController,
            decoration: const InputDecoration(
              labelText: 'Minor',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset controllers to original values
                  _nameController.text = _userData['name'] ?? '';
                  _bioController.text = _userData['bio'] ?? '';
                  _majorController.text = _userData['major'] ?? '';
                  _minorController.text = _userData['minor'] ?? '';
                });
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}