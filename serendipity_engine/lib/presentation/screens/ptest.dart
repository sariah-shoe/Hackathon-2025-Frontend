import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serendipity_engine/services/api_service.dart';

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
  bool userInteracted = false; // Track if user has interacted with this question

  PersonalityAnswer({required this.questionId, this.answerScore, this.userInteracted = false});

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer_score': answerScore,
    };
  }
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
  final ApiService _apiService = ApiService();
  List<PersonalityQuestion> _questions = [];
  Map<int, PersonalityAnswer> _answers = {}; // Map questionId to Answer object
  bool _isLoading = true;
  String? _error;
  bool _lastKnownValidity = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalQuestions = 0;

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

    try {
      final response = await _apiService.get('personality-questions/');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Convert JSON to question objects
        List<PersonalityQuestion> questions = data
            .map((json) => PersonalityQuestion.fromJson(json))
            .toList();
        
        // Shuffle the questions (preserving the order property for reference)
        final Random random = Random();
        questions.shuffle(random);
        
        setState(() {
          _questions = questions;
          _totalQuestions = questions.length;
          
          // Initialize answers map with default value of 3 (neutral)
          _answers = {
            for (var q in _questions) 
              q.id: PersonalityAnswer(questionId: q.id, answerScore: 3)
          };

          if (_questions.isNotEmpty) {
            _answers[_questions[0].id]?.userInteracted = true;
          }
          
          _isLoading = false;
        });
        
        // Since all questions now have a default answer, check validity
        _checkValidityAndSendData();
      } else {
        // Fall back to direct API call if service fails
        final directUrl = Uri.parse('${ApiService.baseUrl}/personality-questions/');
        final directResponse = await http.get(directUrl);
        
        if (directResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(directResponse.body);
          
          // Convert JSON to question objects
          List<PersonalityQuestion> questions = data
              .map((json) => PersonalityQuestion.fromJson(json))
              .toList();
          
          // Shuffle the questions
          final Random random = Random();
          questions.shuffle(random);
          
          setState(() {
            _questions = questions;
            _totalQuestions = questions.length;
            
            // Initialize answers map with default value of 3 (neutral)
            _answers = {
              for (var q in _questions)
                q.id: PersonalityAnswer(questionId: q.id, answerScore: 3)
            };
            
            _isLoading = false;
          });
          
          // Since all questions now have a default answer, check validity
          _checkValidityAndSendData();
        } else {
          throw Exception('Failed to load questions (${response.statusCode})');
        }
      }
    } catch (e) {
      setState(() {
        _error = "Error fetching questions: $e";
        _isLoading = false;
      });
      widget.onValidityChanged(false); // Ensure invalid on error
    }
  }
  
  bool _isFormComplete() {
    return _answers.values.every((answer) => answer.userInteracted == true);
  }

  void _updateAnswer(int questionId, int score) {
    setState(() {
      if (_answers.containsKey(questionId)) {
        _answers[questionId]!.answerScore = score;
        _answers[questionId]!.userInteracted = true; // Mark as user-interacted
      }
    });
    widget.onValidityChanged(_isFormComplete());
    _checkValidityAndSendData();
  }

  void _checkValidityAndSendData() {
    // Test is valid if all questions have a non-null answer score
    // (which they all will by default)
    bool allAnswered = _answers.values.every((answer) => answer.answerScore != null);
    final currentValidity = !_isLoading && _error == null && allAnswered;

    if (_lastKnownValidity != currentValidity) {
       widget.onValidityChanged(currentValidity);
       _lastKnownValidity = currentValidity;
    }

    // Always send data with all answers that have scores (which should be all of them)
    final List<Map<String, dynamic>> formattedAnswers = _answers.values
        .where((answer) => answer.answerScore != null)
        .map((answer) => answer.toJson())
        .toList();

    widget.onDataChanged({'personality_answers': formattedAnswers});
  }

  void _nextQuestion() {
    if (_currentPage < _totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 16),
            Text("Loading personality questions...", 
                 style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!, 
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchQuestions,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No personality questions found.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    final int interactedCount = _answers.values.where((a) => a.userInteracted).length;
    final double rawProgress = interactedCount / _totalQuestions;
    final int displayProgress = interactedCount == _totalQuestions ? 100 : (rawProgress * 100).round();

    // Display questions in a PageView for swiping
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Personality Assessment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentPage + 1} of $_totalQuestions',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$displayProgress% Complete',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _answers.values.where((a) => a.userInteracted).length / _totalQuestions,
                  color: Colors.amber,
                  backgroundColor: Colors.amber.shade100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Questions PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  final questionId = _questions[index].id;
                  if (_answers.containsKey(questionId) && !_answers[questionId]!.userInteracted) {
                    _answers[questionId]!.userInteracted = true;
                  }
                });
                widget.onValidityChanged(_isFormComplete());

              },
              itemBuilder: (context, index) {
                final question = _questions[index];
                final answer = _answers[question.id];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.text,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'How accurately does this statement describe you?',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        // Rating selector
                        Column(
                          children: [
                            Slider(
                              value: (answer?.answerScore ?? 3).toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: _getLabelText(answer?.answerScore),
                              onChanged: (value) {
                                _updateAnswer(question.id, value.round());
                              },
                              activeColor: Colors.amber,
                              inactiveColor: Colors.amber.shade100,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Very\nInaccurate', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                                  Text('Moderately\nInaccurate', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                                  Text('Neither Accurate\nNor Inaccurate', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                                  Text('Moderately\nAccurate', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                                  Text('Very\nAccurate', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                ElevatedButton.icon(
                  onPressed: _currentPage > 0 ? _previousQuestion : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _currentPage > 0 ? Colors.black : Colors.grey[700],
                    backgroundColor: _currentPage > 0 ? Colors.amber : Colors.grey[300],
                  ),
                ),
                // Next button
                ElevatedButton.icon(
                  onPressed: _currentPage < _totalQuestions - 1 ? _nextQuestion : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _currentPage < _totalQuestions - 1 ? Colors.black : Colors.grey[700],
                    backgroundColor: _currentPage < _totalQuestions - 1 ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getLabelText(int? score) {
    if (score == null) return 'Select';
    
    switch (score) {
      case 1: return 'Very Inaccurate';
      case 2: return 'Moderately Inaccurate';
      case 3: return 'Neither Accurate Nor Inaccurate';
      case 4: return 'Moderately Accurate';
      case 5: return 'Very Accurate';
      default: return 'Select';
    }
  }
}