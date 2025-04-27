import 'package:flutter/material.dart';
import '../personality_test/ask_question.dart'; // Import the question screen

class PTestScreen extends StatefulWidget {
  const PTestScreen({super.key});

  @override
  State<PTestScreen> createState() => _PTestScreenState();
}

class _PTestScreenState extends State<PTestScreen> {
  // Define the Big Five personality questions (example questions)
  // You should replace these with the actual questions you intend to use.
  final List<String> _questions = [
    "I see myself as someone who is talkative.", // Extraversion
    "I see myself as someone who tends to find fault with others.", // Agreeableness (reversed)
    "I see myself as someone who does a thorough job.", // Conscientiousness
    "I see myself as someone who is depressed, blue.", // Neuroticism
    "I see myself as someone who is original, comes up with new ideas.", // Openness
    "I see myself as someone who is reserved.", // Extraversion (reversed)
    "I see myself as someone who is helpful and unselfish with others.", // Agreeableness
    "I see myself as someone who can be somewhat careless.", // Conscientiousness (reversed)
    "I see myself as someone who is relaxed, handles stress well.", // Neuroticism (reversed)
    "I see myself as someone who is curious about many different things.", // Openness
    // Add more questions as needed (e.g., 10 per trait for BFI-44)
  ];

  int _currentQuestionIndex = 0;
  final Map<int, AgreementLevel> _answers = {}; // Store answers: {questionIndex: answer}

  void _handleAnswerSelected(AgreementLevel answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer; // Store the answer
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++; // Move to the next question
      } else {
        // Test finished - handle completion
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    // Example: Show a dialog upon completion
    // In a real app, you might navigate away, save data, etc.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Complete'),
        content: Text('You have answered all questions. Answers: ${_answers.length} recorded.'), // Simple confirmation
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Potentially navigate back or to the next part of registration
              // Navigator.of(context).pop(); // Example: Go back from PTestScreen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
     // You can process the _answers map here (e.g., calculate scores, send to backend)
     print("Collected Answers: $_answers");
     _calculateScores(); // Example function call
  }

  // Example function to calculate scores (implement actual logic based on Big Five scoring)
  void _calculateScores() {
    // This is where you'd implement the scoring logic based on the _answers map
    // Remember to handle reversed items appropriately.
    print("Calculating scores based on answers...");
    // Example: Iterate through answers and sum scores per trait
    // int extraversionScore = 0;
    // ... calculate scores for all five traits ...
  }


  @override
  Widget build(BuildContext context) {
    // Use AskQuestionScreen to display the current question
    return AskQuestionScreen(
      key: ValueKey(_currentQuestionIndex), // Important: Use a key to force widget rebuild
      questionText: _questions[_currentQuestionIndex],
      onAnswerSelected: _handleAnswerSelected,
    );
  }
}