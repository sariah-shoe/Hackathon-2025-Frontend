import 'package:flutter/material.dart';

// Enum to represent the possible answers
enum AgreementLevel {
  stronglyDisagree,
  disagree,
  neutral,
  agree,
  stronglyAgree,
}

// Helper to get display text for each level
extension AgreementLevelExtension on AgreementLevel {
  String get displayText {
    switch (this) {
      case AgreementLevel.stronglyDisagree:
        return 'Strongly Disagree';
      case AgreementLevel.disagree:
        return 'Disagree';
      case AgreementLevel.neutral:
        return 'Neutral';
      case AgreementLevel.agree:
        return 'Agree';
      case AgreementLevel.stronglyAgree:
        return 'Strongly Agree';
    }
  }

  // Optional: Assign a numerical value if needed for scoring
  int get scoreValue {
     switch (this) {
      case AgreementLevel.stronglyDisagree:
        return 1;
      case AgreementLevel.disagree:
        return 2;
      case AgreementLevel.neutral:
        return 3;
      case AgreementLevel.agree:
        return 4;
      case AgreementLevel.stronglyAgree:
        return 5;
    }
  }
}


class AskQuestionScreen extends StatefulWidget {
  final String questionText;
  final Function(AgreementLevel) onAnswerSelected;

  const AskQuestionScreen({
    super.key,
    required this.questionText,
    required this.onAnswerSelected,
  });

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  AgreementLevel? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Minimalist AppBar
      appBar: AppBar(
        title: const Text('Personality Question'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Text(
              widget.questionText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40), // Spacing

            // Answer Buttons - Using ToggleButtons for a connected look
            Center( // Center the ToggleButtons
              child: ToggleButtons(
                 isSelected: AgreementLevel.values.map((level) => _selectedAnswer == level).toList(),
                 onPressed: (int index) {
                   setState(() {
                     _selectedAnswer = AgreementLevel.values[index];
                   });
                   widget.onAnswerSelected(_selectedAnswer!); // Notify parent
                 },
                 borderRadius: BorderRadius.circular(8.0),
                 selectedBorderColor: Theme.of(context).colorScheme.primary,
                 selectedColor: Colors.white, // Text color when selected
                 fillColor: Theme.of(context).colorScheme.primary, // Background color when selected
                 color: Theme.of(context).colorScheme.primary, // Text color when not selected
                 constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0), // Ensure buttons have reasonable size
                 children: AgreementLevel.values.map((level) {
                   // Using simple text for minimalist look, could use icons
                   return Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
                     child: Text(
                       level.displayText.split(' ').join('\n'), // Split text for better fit if needed
                       textAlign: TextAlign.center,
                       style: const TextStyle(fontSize: 12), // Smaller font for buttons
                     ),
                   );
                 }).toList(),
              ),
            ),

            const Spacer(), // Pushes the (optional) next button down

            // Add a button to proceed to the next question
            // might want to enable this only after an answer is selected
            // ElevatedButton(
            //   onPressed: _selectedAnswer == null ? null : () {
            //     // Handle navigation to next question or completion
            //   },
            //   child: const Text('Next'),
            // ),
          ],
        ),
      ),
    );
  }
}