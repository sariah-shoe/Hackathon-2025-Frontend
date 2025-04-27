import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Assuming these screens exist and are designed to be part of the flow
import 'create_account.dart'; // Step 1: Email/Password
import 'ptest.dart';          // Step 2: Personality Test (Placeholder)

// Placeholder for a screen - replace with actual PTest screen later
class PersonalityTestScreen extends StatelessWidget {
  final Function(Map<String, dynamic> data) onDataChanged;
  final Function(bool isValid) onValidityChanged;

  const PersonalityTestScreen({
    super.key,
    required this.onDataChanged,
    required this.onValidityChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Simulate validity change after a delay
    Future.delayed(const Duration(seconds: 1), () => onValidityChanged(true));
    // Simulate data change
    Future.delayed(const Duration(seconds: 1), () => onDataChanged({'personality_answers': [{'question_id': 1, 'answer_score': 3}]}));

    return const Center(child: Text('Personality Test Screen (Placeholder)'));
  }
}


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final Map<String, dynamic> _registrationData = {};
  // Tracks if the *current* page's inputs are valid for proceeding
  bool _isCurrentPageValid = false;

  // Define the registration steps/screens
  late final List<Widget> _registrationPages;

  @override
  void initState() {
    super.initState();
    _registrationPages = [
      CreateAccountScreen( // Assuming CreateAccountScreen is updated for this
        onDataChanged: (data) => _updateRegistrationData(data),
        onValidityChanged: (isValid) => _updatePageValidity(isValid),
      ),
      // AcademicScreen removed as fields are now in CreateAccountScreen
      PersonalityTestScreen( // Now Step 2
        onDataChanged: (data) => _updateRegistrationData(data),
        onValidityChanged: (isValid) => _updatePageValidity(isValid),
      ),
    ];
    // Initial validity check for the first page might be needed depending on CreateAccountScreen
    // For now, assume the first page starts invalid until interaction.
    _isCurrentPageValid = false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateRegistrationData(Map<String, dynamic> data) {
    setState(() {
      _registrationData.addAll(data);
      // Optional: Re-check validity if data change might affect it
      // _checkCurrentPageValidity();
    });
    print("Updated Registration Data: $_registrationData"); // For debugging
  }

  void _updatePageValidity(bool isValid) {
    // Only update if the validity state actually changes
    if (_isCurrentPageValid != isValid) {
      setState(() {
        _isCurrentPageValid = isValid;
      });
       print("Page $_currentPageIndex Validity: $_isCurrentPageValid"); // For debugging
    }
  }

  void _nextPage() {
    if (_currentPageIndex < _registrationPages.length - 1) {
      // Reset validity for the next page before moving
      setState(() {
         _isCurrentPageValid = false; // Assume next page starts invalid
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page: Submit registration
      _submitRegistration();
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
       // Reset validity for the previous page before moving (might need adjustment)
       // This depends on whether previous pages retain state. For simplicity,
       // we might need the child pages to report their validity when revisited.
       // Or, store validity per page. Let's assume it needs re-validation for now.
       setState(() {
         _isCurrentPageValid = false; // Needs re-check upon revisit
       });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitRegistration() async {
    print("Submitting Registration Data: $_registrationData");
    final messenger = ScaffoldMessenger.of(context); // Store for use after async gap
    messenger.showSnackBar(
      const SnackBar(content: Text('Registering...')),
    );

    // **TODO:** Replace with your actual API base URL
    final url = Uri.parse('http://127.0.0.1:8000/api/onboarding/'); // Example local URL

    try {
      http.Response response;
      final String? imagePath = _registrationData.remove('image_path'); // Remove path from data map

      // Use Multipart request if image exists
      if (imagePath != null && imagePath.isNotEmpty) {
        var request = http.MultipartRequest('POST', url);

        // Add image file
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));

        // Add other fields as strings, JSON encoding lists/maps
        _registrationData.forEach((key, value) {
          if (value != null) {
             if (value is List || value is Map) {
               request.fields[key] = jsonEncode(value); // Encode lists/maps
             } else {
               request.fields[key] = value.toString(); // Convert others to string
             }
          }
          // Handle null values if necessary, API might expect empty strings or omit the key
        });

         print("Multipart Request Fields: ${request.fields}");
         print("Multipart Request Files: ${request.files.map((f) => f.filename).toList()}");


        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);

      } else {
        // Use standard POST if no image
         // Need to JSON encode lists/maps before sending the whole body
         final Map<String, dynamic> bodyToSend = {};
         _registrationData.forEach((key, value) {
            // API likely expects nulls to be omitted or explicitly null
            bodyToSend[key] = value;
         });

         print("JSON Request Body: ${jsonEncode(bodyToSend)}");

        response = await http.post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(bodyToSend), // Send the processed map
        );
      }

      messenger.hideCurrentSnackBar(); // Hide loading indicator

      if (response.statusCode == 201) {
        print('Registration Successful: ${response.body}');
        messenger.showSnackBar(
          const SnackBar(content: Text('Registration Successful!'), backgroundColor: Colors.green),
        );
        // Navigate to Login or Home screen
        // Navigator.of(context).pushReplacementNamed('/login'); // Example
      } else {
        print('Registration Failed: ${response.statusCode} ${response.body}');
        String errorMessage = 'Registration failed (${response.statusCode}).';
        try {
          final responseBody = jsonDecode(response.body);
          // Enhance error parsing based on actual API responses
          if (responseBody is Map) {
             if (responseBody.containsKey('detail')) {
                errorMessage = responseBody['detail'];
             } else {
                // Concatenate field-specific errors
                errorMessage = responseBody.entries
                    .map((e) => '${e.key}: ${e.value is List ? e.value.join(', ') : e.value}')
                    .join('\n');
             }
          } else if (responseBody is String) {
             errorMessage = responseBody; // Use string response directly
          }
        } catch (e) {
          errorMessage = 'Registration failed (${response.statusCode}). Could not parse error details.';
          print("Error parsing error response: $e");
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage, maxLines: 5, overflow: TextOverflow.ellipsis),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5), // Show longer for errors
          ),
        );
      }
    } catch (e, stackTrace) {
       messenger.hideCurrentSnackBar(); // Hide loading indicator
      print('Registration Error: $e\n$stackTrace'); // Log stack trace too
      messenger.showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPageIndex == _registrationPages.length - 1;
    final bool canGoBack = _currentPageIndex > 0;
    // Forward button is enabled if the current page is valid
    final bool canGoForward = _isCurrentPageValid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account (${_currentPageIndex + 1}/${_registrationPages.length})', // Dynamic title
          style: const TextStyle(color: Colors.amber), // Keep your style
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // Keep your style
        // Optional: Add back button in AppBar if needed, but might conflict with bottom nav
        // leading: canGoBack ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _previousPage) : null,
      ),
      body: PageView(
        controller: _pageController,
        // Disable swiping between pages
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
            // **Important:** When page changes, validity needs to be re-evaluated
            // by the newly displayed child widget. Resetting here ensures the
            // forward button is disabled until the new page reports validity.
            _isCurrentPageValid = false;
          });
           print("Moved to page: $_currentPageIndex"); // For debugging
        },
        children: _registrationPages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              onPressed: canGoBack ? _previousPage : null, // Disable if not possible
              style: ElevatedButton.styleFrom(
                foregroundColor: canGoBack ? Colors.black : Colors.grey[700], // Text/Icon color
                backgroundColor: canGoBack ? Colors.amber : Colors.grey[300], // Button background
              ),
            ),

            // Forward/Submit Button
            ElevatedButton.icon(
              icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
              label: Text(isLastPage ? 'Submit' : 'Next'),
              onPressed: canGoForward ? _nextPage : null, // Disable if page invalid
               style: ElevatedButton.styleFrom(
                foregroundColor: canGoForward ? Colors.black : Colors.grey[700], // Text/Icon color
                backgroundColor: canGoForward ? Colors.amber : Colors.grey[300], // Button background
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Mock screens removed, using actual imported screens ---
