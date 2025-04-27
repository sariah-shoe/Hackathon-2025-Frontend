import 'dart:io'; // Required for File type if using image_picker < 1.0
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

// --- Reusable Widget for Dynamic Text List Input ---
class DynamicTextListInput extends StatefulWidget {
  final String label;
  final List<String> initialItems;
  final Function(List<String> items) onListChanged;

  const DynamicTextListInput({
    super.key,
    required this.label,
    required this.onListChanged,
    this.initialItems = const [],
  });

  @override
  State<DynamicTextListInput> createState() => _DynamicTextListInputState();
}

class _DynamicTextListInputState extends State<DynamicTextListInput> {
  late final List<String> _items;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(widget.initialItems);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_items.contains(text)) {
      setState(() {
        _items.add(text);
        _textController.clear();
      });
      widget.onListChanged(_items);
    }
  }

  void _removeItem(String item) {
    setState(() {
      _items.remove(item);
    });
    widget.onListChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type and press Add',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onFieldSubmitted: (_) => _addItem(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _items.map((item) => Chip(
              label: Text(item),
              onDeleted: () => _removeItem(item),
              deleteIconColor: Colors.red.shade700,
            )).toList(),
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}

// --- Reusable Widget for Dynamic Course List Input ---
class DynamicCourseListInput extends StatefulWidget {
  final String label;
  final List<Map<String, String>> initialItems;
  final Function(List<Map<String, String>> items) onListChanged;

  const DynamicCourseListInput({
    super.key,
    required this.label,
    required this.onListChanged,
    this.initialItems = const [],
  });

  @override
  State<DynamicCourseListInput> createState() => _DynamicCourseListInputState();
}

class _DynamicCourseListInputState extends State<DynamicCourseListInput> {
  late final List<Map<String, String>> _courses;
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _departmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
    _courses = List<Map<String, String>>.from(widget.initialItems.map((item) => Map<String, String>.from(item)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _addCourse() {
    if (_formKey.currentState!.validate()) { // Validate the input fields
      final name = _nameController.text.trim();
      final number = _numberController.text.trim();
      final department = _departmentController.text.trim();

      setState(() {
        _courses.add({
          'name': name,
          'number': number,
          'department': department,
        });
        _nameController.clear();
        _numberController.clear();
        _departmentController.clear();
        // Reset validation state after successful add
        _formKey.currentState!.reset();
      });
      widget.onListChanged(_courses); // Notify parent
    }
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
    });
    widget.onListChanged(_courses); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Form( // Wrap input fields in a Form for validation
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course Name', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: 'Course Number', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Number required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Department required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _addCourse,
            icon: const Icon(Icons.add),
            label: const Text('Add Course'),
          ),
        ),
        const SizedBox(height: 8),
        if (_courses.isNotEmpty)
          ListView.builder(
            shrinkWrap: true, // Important inside SingleChildScrollView
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the list
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              return Card( // Use Card for better visual separation
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text('${course['name']} (${course['number']})'),
                  subtitle: Text(course['department'] ?? 'N/A'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeCourse(index),
                    tooltip: 'Remove Course',
                  ),
                  dense: true,
                ),
              );
            },
          ),
        const SizedBox(height: 15), // Spacing after the input group
      ],
    );
  }
}
// --- End of New Widget ---


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
  // Updated Socials Controllers
  final _socialsSnapchatController = TextEditingController();
  final _socialsInstagramController = TextEditingController();
  final _socialsFacebookController = TextEditingController();
  final _socialsXController = TextEditingController();
  final _socialsDiscordController = TextEditingController();
  final _socialsPhoneController = TextEditingController();
  final _socialsOtherController = TextEditingController();


  // State variables
  XFile? _imageFile;
  String? _yearInSchool;
  List<String> _majors = [];
  List<String> _minors = [];
  List<String> _interests = [];
  List<String> _activities = [];
  List<Map<String, String>> _coursesTaking = [];
  List<Map<String, String>> _favoriteCourses = [];

  final List<String> _yearOptions = ['FR', 'SO', 'JR', 'SR', 'GR', 'OT'];

  bool _lastKnownValidity = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkValidity);
    _passwordController.addListener(_checkValidity);
    // Add listeners for optional fields that just trigger data updates
    _firstNameController.addListener(_sendDataUpdate);
    _lastNameController.addListener(_sendDataUpdate);
    _preferredNameController.addListener(_sendDataUpdate);
    _socialsSnapchatController.addListener(_sendDataUpdate);
    _socialsInstagramController.addListener(_sendDataUpdate);
    _socialsFacebookController.addListener(_sendDataUpdate);
    _socialsXController.addListener(_sendDataUpdate);
    _socialsDiscordController.addListener(_sendDataUpdate);
    _socialsPhoneController.addListener(_sendDataUpdate);
    _socialsOtherController.addListener(_sendDataUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkValidity());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _preferredNameController.dispose();
    // Dispose new socials controllers
    _socialsSnapchatController.dispose();
    _socialsInstagramController.dispose();
    _socialsFacebookController.dispose();
    _socialsXController.dispose();
    _socialsDiscordController.dispose();
    _socialsPhoneController.dispose();
    _socialsOtherController.dispose();
    super.dispose();
  }

  void _checkValidity() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final imageValid = _imageFile != null;
    final currentValidity = formValid && imageValid;

    if (_lastKnownValidity != currentValidity) {
      widget.onValidityChanged(currentValidity);
      _lastKnownValidity = currentValidity;
    }
    // Always send data update, even if validity hasn't changed,
    // because optional fields might have changed.
    _sendDataUpdate();
  }

  void _sendDataUpdate() {
    // Construct the updated socials map
    final socialsMap = <String, String>{};
    if (_socialsSnapchatController.text.trim().isNotEmpty) {
      socialsMap['snapchat'] = _socialsSnapchatController.text.trim();
    }
    if (_socialsInstagramController.text.trim().isNotEmpty) {
      socialsMap['instagram'] = _socialsInstagramController.text.trim();
    }
    if (_socialsFacebookController.text.trim().isNotEmpty) {
      socialsMap['facebook'] = _socialsFacebookController.text.trim();
    }
    if (_socialsXController.text.trim().isNotEmpty) {
      socialsMap['x'] = _socialsXController.text.trim(); // Key for X/Twitter
    }
    if (_socialsDiscordController.text.trim().isNotEmpty) {
      socialsMap['discord'] = _socialsDiscordController.text.trim();
    }
    if (_socialsPhoneController.text.trim().isNotEmpty) {
      socialsMap['phone'] = _socialsPhoneController.text.trim();
    }
     if (_socialsOtherController.text.trim().isNotEmpty) {
      socialsMap['other'] = _socialsOtherController.text.trim();
    }

    widget.onDataChanged({
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'preferred_name': _preferredNameController.text.trim(),
      //'image_path': _imageFile?.path,
      'year_in_school': _yearInSchool,
      'socials': socialsMap, // Send updated map
      'majors': _majors,
      'minors': _minors,
      'interests': _interests,
      'activities': _activities,
      'courses_taking': _coursesTaking,
      'favorite_courses': _favoriteCourses,
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
        // No need to call _sendDataUpdate here, _checkValidity will do it
        _checkValidity();
      }
    } catch (e) {
      print("Image picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          // Use autovalidateMode to provide feedback as user types (optional)
          // autovalidateMode: AutovalidateMode.onUserInteraction,
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
                // onChanged: (_) => _checkValidity(), // Use listener instead
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
                // onChanged: (_) => _checkValidity(), // Use listener instead
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
                 // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                keyboardType: TextInputType.name,
                 // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
               const SizedBox(height: 15),
              TextFormField(
                controller: _preferredNameController,
                decoration: const InputDecoration(labelText: 'Preferred Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                keyboardType: TextInputType.name,
                 // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),

              // --- Profile Image (Required) ---
              //Row(
              //  //children: [
              //  //  //Expanded(
              //  //  //  child: Text(
              //  //  //    _imageFile == null ? 'Profile Picture *' : 'Picture Selected: ${_imageFile!.name}',
              //  //  //    style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //  //  //      color: _imageFile == null ? Theme.of(context).colorScheme.error : null
              //  //  //    ),
              //  //  //  ),
              //  //  //),
              //  //  IconButton(
              //  //    icon: const Icon(Icons.photo_camera),
              //  //    onPressed: _pickImage,
              //  //    tooltip: 'Select Profile Picture',
              //  //  ),
              //  //  if (_imageFile != null)
              //  //    IconButton(
              //  //      icon: const Icon(Icons.delete_outline, color: Colors.red),
              //  //      onPressed: () {
              //  //        setState(() => _imageFile = null);
              //  //         // No need to call _sendDataUpdate here, _checkValidity will do it
              //  //         _checkValidity();
              //  //       },
              //  //       tooltip: 'Remove Picture',
              //  //     ),
              //  // ],
              // ),
              // if (_imageFile == null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8.0),
              //     child: Text(
              //       'Profile picture is required.',
              //       style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              //     ),
              //   ),
              //  if (_imageFile != null) ...[
              //    const SizedBox(height: 10),
              //    Center(child: Image.file(File(_imageFile!.path), height: 100, width: 100, fit: BoxFit.cover)),
              //    const SizedBox(height: 10),
              //  ],
              // const SizedBox(height: 15),


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
                    _sendDataUpdate(); // Year change only affects optional data
                 },
               ),
               const SizedBox(height: 15),
               DynamicTextListInput(
                 label: 'Majors',
                 initialItems: _majors,
                 onListChanged: (updatedList) {
                   // No need for setState here as child manages its state
                   _majors = updatedList;
                   _sendDataUpdate();
                 },
               ),
               DynamicTextListInput(
                 label: 'Minors',
                 initialItems: _minors,
                 onListChanged: (updatedList) {
                   _minors = updatedList;
                   _sendDataUpdate();
                 },
               ),

               // --- Activities & Interests (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Activities & Interests (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
               DynamicTextListInput(
                 label: 'Interests',
                 initialItems: _interests,
                 onListChanged: (updatedList) {
                   _interests = updatedList;
                   _sendDataUpdate();
                 },
               ),
               DynamicTextListInput(
                 label: 'Activities',
                 initialItems: _activities,
                 onListChanged: (updatedList) {
                   _activities = updatedList;
                   _sendDataUpdate();
                 },
               ),

               // --- Courses (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Courses (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
               DynamicCourseListInput(
                 label: 'Courses Taking',
                 initialItems: _coursesTaking,
                 onListChanged: (updatedList) {
                   _coursesTaking = updatedList;
                   _sendDataUpdate();
                 },
               ),
               DynamicCourseListInput(
                 label: 'Favorite Courses',
                 initialItems: _favoriteCourses,
                 onListChanged: (updatedList) {
                   _favoriteCourses = updatedList;
                   _sendDataUpdate();
                 },
               ),


              // --- Socials (Optional) ---
               const Divider(),
               const SizedBox(height: 15),
               Text('Socials (Optional)', style: Theme.of(context).textTheme.headlineSmall),
               const SizedBox(height: 15),
              TextFormField(
                controller: _socialsSnapchatController,
                decoration: const InputDecoration(labelText: 'Snapchat Username', border: OutlineInputBorder()),
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _socialsInstagramController,
                decoration: const InputDecoration(labelText: 'Instagram Handle', border: OutlineInputBorder()),
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
               TextFormField(
                controller: _socialsFacebookController,
                decoration: const InputDecoration(labelText: 'Facebook Profile URL', border: OutlineInputBorder()),
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
               TextFormField(
                controller: _socialsXController,
                decoration: const InputDecoration(labelText: 'X (Twitter) Handle', border: OutlineInputBorder()),
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
               TextFormField(
                controller: _socialsDiscordController,
                decoration: const InputDecoration(labelText: 'Discord Username', border: OutlineInputBorder()),
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
               TextFormField(
                controller: _socialsPhoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15),
               TextFormField(
                controller: _socialsOtherController,
                decoration: const InputDecoration(labelText: 'Other Social/Contact', border: OutlineInputBorder()),
                // onChanged: (_) => _sendDataUpdate(), // Use listener instead
              ),
              const SizedBox(height: 15), // Add final spacing at the bottom

            ],
          ),
        ),
      ),
    );
  }
}