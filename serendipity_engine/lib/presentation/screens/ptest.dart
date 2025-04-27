import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model for a personality question fetched from the API
class PersonalityQuestion {
  final int id;
  final String text;
  final int order;

  PersonalityQuestion({required this.id, required this.text, required this.order});

  factory PersonalityQuestion.fromJson(Map<String, dynamic> json) {
    return PersonalityQuestion(
      id: json['id'],
      text: json['text'],
      order: json['order'],
    );
  }
}

// Model for storing an answer locally
class PersonalityAnswer {
  final int questionId;
  int? answerScore; // Nullable initially

  PersonalityAnswer({required this.questionId, this.answerScore});
}


class PersonalityTestScreen extends StatefulWidget {
  final Function(Map<String, dynamic> data) onDataChanged;
  final Function(bool isValid) onValidityChanged;

  const PersonalityTestScreen({
    super.key,
    required this.onDataChanged,
    required this.onValidityChanged,
  });

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  List<PersonalityQuestion> _questions = [];
  Map<int, PersonalityAnswer> _answers = {}; // Map questionId to Answer object
  bool _isLoading = true;
  String? _error;
  bool _lastKnownValidity = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    // Initially invalid until questions are loaded and answered
    widget.onValidityChanged(false);
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // **TODO:** Replace with your actual API base URL
    final url = Uri.parse('http://127.0.0.1:8000/api/personality-questions/'); // Example local URL

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _questions = data.map((json) => PersonalityQuestion.fromJson(json)).toList();
          // Initialize answers map
          _answers = {
            for (var q in _questions) q.id: PersonalityAnswer(questionId: q.id)
          };
          _isLoading = false;
        });
        _checkValidityAndSendData(); // Check validity after loading
      } else {
        throw Exception('Failed to load questions (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _error = "Error fetching questions: $e";
        _isLoading = false;
      });
      widget.onValidityChanged(false); // Ensure invalid on error
    }
  }

  void _updateAnswer(int questionId, int score) {
    setState(() {
      if (_answers.containsKey(questionId)) {
        _answers[questionId]!.answerScore = score;
      }
    });
    _checkValidityAndSendData();
  }

  void _checkValidityAndSendData() {
    // Valid if all questions have a non-null answer score
    bool allAnswered = _answers.values.every((answer) => answer.answerScore != null);
    final currentValidity = !_isLoading && _error == null && allAnswered;

    if (_lastKnownValidity != currentValidity) {
       widget.onValidityChanged(currentValidity);
       _lastKnownValidity = currentValidity;
    }

    if (currentValidity) {
      // Format data for the API
      final List<Map<String, dynamic>> formattedAnswers = _answers.values
          .map((answer) => {
                'question_id': answer.questionId,
                'answer_score': answer.answerScore,
              })
          .toList();

      widget.onDataChanged({'personality_answers': formattedAnswers});
    } else {
       // Optionally send empty/partial data if needed, or ensure parent clears it
       // widget.onDataChanged({'personality_answers': []});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchQuestions,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
       return const Center(child: Text('No personality questions found.'));
    }

    // Display questions in a ListView
    return Scaffold( // Added Scaffold for structure
       body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          final answer = _answers[question.id];

          return Card( // Wrap each question in a Card for better visual separation
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}: ${question.text}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 15),
                  // Using a Slider for 1-5 score selection
                  Slider(
                    value: (answer?.answerScore ?? 3).toDouble(), // Default to middle value if null
                    min: 1,
                    max: 5,
                    divisions: 4, // 5 points means 4 divisions
                    label: (answer?.answerScore ?? 'Select').toString(),
                    onChanged: (value) {
                      _updateAnswer(question.id, value.round());
                    },
                    activeColor: Colors.amber,
                    inactiveColor: Colors.amber.shade100,
                  ),
                   // Display labels for slider
                   const Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('1'),
                       Text('2'),
                       Text('3'),
                       Text('4'),
                       Text('5'),
                     ],
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}