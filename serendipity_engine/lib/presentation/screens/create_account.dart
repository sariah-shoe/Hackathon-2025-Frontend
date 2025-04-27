import 'dart:io'; // Required for File type if using image_picker < 1.0
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

class CreateAccountScreen extends StatefulWidget {
  final Function(Map<String, dynamic> data) onDataChanged;
  final Function(bool isValid) onValidityChanged;

  const CreateAccountScreen({
    super.key,
    required this.onDataChanged,
    required this.onValidityChanged,
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _preferredNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _socialsLinkedInController = TextEditingController();
  final _socialsGithubController = TextEditingController();
  // Add more social controllers as needed

  // State variables
  XFile? _imageFile; // Stores the selected image file
  String? _yearInSchool;
  final List<String> _selectedMajors = [];
  final List<String> _selectedMinors = [];
  final List<String> _selectedInterests = [];
  final List<String> _selectedCoursesTaking = [];
  final List<String> _selectedFavoriteCourses = [];
  final List<String> _selectedClubs = [];

  // Mock options - These should ideally be fetched from the backend
  final List<String> _majorOptions = ['Computer Science', 'Mathematics', 'Physics', 'Biology', 'Chemistry'];
  final List<String> _minorOptions = ['Computer Science', 'Mathematics', 'Physics', 'Statistics', 'Art History'];
  final List<String> _interestOptions = ['Board Games', 'Hiking', 'Python', 'Reading', 'Music', 'Movies'];
  final List<String> _courseOptions = ['COMP 1800', 'COMP 2800', 'MATH 3100', 'PHYS 1600', 'CHEM 1210'];
  final List<String> _clubOptions = ['Coding Club', 'Board Game Club', 'Hiking Club', 'Music Club'];
  final List<String> _yearOptions = ['FR', 'SO', 'JR', 'SR', 'GR', 'OT']; // From API spec

  bool _lastKnownValidity = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to required fields for validity check
    _emailController.addListener(_checkValidity);
    _passwordController.addListener(_checkValidity);

    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkValidity());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _preferredNameController.dispose();
    _departmentController.dispose();
    _socialsLinkedInController.dispose();
    _socialsGithubController.dispose();
    super.dispose();
  }

  void _checkValidity() {
    // Validity depends only on required fields: email and password being valid
    final currentValidity = _formKey.currentState?.validate() ?? false;

    if (_lastKnownValidity != currentValidity) {
      widget.onValidityChanged(currentValidity);
      _lastKnownValidity = currentValidity;
    }

    // Always send data updates regardless of validity,
    // as optional fields might change. The parent decides if it can proceed.
    _sendDataUpdate();
  }

  void _sendDataUpdate() {
     // Construct the socials map
    final socialsMap = <String, String>{};
    if (_socialsLinkedInController.text.trim().isNotEmpty) {
      socialsMap['linkedin'] = _socialsLinkedInController.text.trim();
    }
    if (_socialsGithubController.text.trim().isNotEmpty) {
      socialsMap['github'] = _socialsGithubController.text.trim();
    }
    // Add other socials...

    widget.onDataChanged({
      'email': _emailController.text.trim(),
      'password': _passwordController.text, // Don't trim password
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'preferred_name': _preferredNameController.text.trim(),
      'image_path': _imageFile?.path, // Send path, actual upload handled later
      'year_in_school': _yearInSchool,
      'department': _departmentController.text.trim(),
      'socials': socialsMap, // Send the constructed map
      'majors': _selectedMajors,
      'minors': _selectedMinors,
      'interests': _selectedInterests,
      'courses_taking': _selectedCoursesTaking,
      'favorite_courses': _selectedFavoriteCourses,
      'clubs': _selectedClubs,
    });
  }


  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        _sendDataUpdate(); // Update data when image changes
      }
    } catch (e) {
      // Handle potential errors, e.g., permissions
      print("Image picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Helper widget for multi-select chips
  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required List<String> selectedItems,
    required ValueChanged<String> onSelected,
    required ValueChanged<String> onDeselected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: options.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    onSelected(item);
                  } else {
                    onDeselected(item);
                  }
                });
                 _sendDataUpdate(); // Update data on chip selection change
              },
              selectedColor: Colors.amber.shade300, // Example styling
              checkmarkColor: Colors.black,
            );
          }).toList(),
        ),
        const SizedBox(height: 15), // Spacing after chip group
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Make the content scrollable
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell Us About Yourself',
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // --- Account Credentials (Required) ---
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // --- Basic Info (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Basic Info (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                keyboardType: TextInputType.name,
                 onChanged: (_) => _sendDataUpdate(),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                keyboardType: TextInputType.name,
                 onChanged: (_) => _sendDataUpdate(),
              ),
               const SizedBox(height: 15),
              TextFormField(
                controller: _preferredNameController,
                decoration: const InputDecoration(labelText: 'Preferred Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                keyboardType: TextInputType.name,
                 onChanged: (_) => _sendDataUpdate(),
              ),
              const SizedBox(height: 15),

              // --- Profile Image (Optional) ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _imageFile == null ? 'Profile Picture (Optional)' : 'Picture Selected: ${_imageFile!.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_camera),
                    onPressed: _pickImage,
                    tooltip: 'Select Profile Picture',
                  ),
                  if (_imageFile != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() => _imageFile = null);
                         _sendDataUpdate();
                      },
                      tooltip: 'Remove Picture',
                    ),
                ],
              ),
               if (_imageFile != null) ...[
                 const SizedBox(height: 10),
                 // Use Image.file for non-web platforms
                 // For web, you might need Image.network(_imageFile!.path) or kIsWeb check
                 Center(child: Image.file(File(_imageFile!.path), height: 100, width: 100, fit: BoxFit.cover)),
                 const SizedBox(height: 10),
               ],
              const SizedBox(height: 15),


              // --- Academic Info (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Academic Info (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _yearInSchool,
                decoration: const InputDecoration(labelText: 'Year in School', border: OutlineInputBorder()),
                items: _yearOptions.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                onChanged: (value) {
                  setState(() => _yearInSchool = value);
                   _sendDataUpdate();
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                 onChanged: (_) => _sendDataUpdate(),
              ),
              const SizedBox(height: 15),
              _buildChipSelector(
                label: 'Majors',
                options: _majorOptions,
                selectedItems: _selectedMajors,
                onSelected: (item) => _selectedMajors.add(item),
                onDeselected: (item) => _selectedMajors.remove(item),
              ),
              _buildChipSelector(
                label: 'Minors',
                options: _minorOptions,
                selectedItems: _selectedMinors,
                onSelected: (item) => _selectedMinors.add(item),
                onDeselected: (item) => _selectedMinors.remove(item),
              ),

               // --- Activities & Interests (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Activities & Interests (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
               _buildChipSelector(
                label: 'Interests',
                options: _interestOptions,
                selectedItems: _selectedInterests,
                onSelected: (item) => _selectedInterests.add(item),
                onDeselected: (item) => _selectedInterests.remove(item),
              ),
               _buildChipSelector(
                label: 'Courses Taking',
                options: _courseOptions,
                selectedItems: _selectedCoursesTaking,
                onSelected: (item) => _selectedCoursesTaking.add(item),
                onDeselected: (item) => _selectedCoursesTaking.remove(item),
              ),
               _buildChipSelector(
                label: 'Favorite Courses',
                options: _courseOptions, // Assuming same list, adjust if different
                selectedItems: _selectedFavoriteCourses,
                onSelected: (item) => _selectedFavoriteCourses.add(item),
                onDeselected: (item) => _selectedFavoriteCourses.remove(item),
              ),
               _buildChipSelector(
                label: 'Clubs',
                options: _clubOptions,
                selectedItems: _selectedClubs,
                onSelected: (item) => _selectedClubs.add(item),
                onDeselected: (item) => _selectedClubs.remove(item),
              ),

              // --- Socials (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Socials (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
              TextFormField(
                controller: _socialsLinkedInController,
                decoration: const InputDecoration(labelText: 'LinkedIn Profile URL', border: OutlineInputBorder(), prefixIcon: Icon(Icons.link)), // Placeholder icon
                 onChanged: (_) => _sendDataUpdate(),
              ),
               const SizedBox(height: 15),
              TextFormField(
                controller: _socialsGithubController,
                decoration: const InputDecoration(labelText: 'GitHub Profile URL', border: OutlineInputBorder(), prefixIcon: Icon(Icons.code)), // Placeholder icon
                 onChanged: (_) => _sendDataUpdate(),
              ),
              // Add more social fields (Instagram, Twitter/X, etc.) as needed

            ],
          ),
        ),
      ),
    );
  }
}