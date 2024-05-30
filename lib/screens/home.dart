import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_calculator/widgets/button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userQuestion = '';
  String userAnwser = '';
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnable = false;
  bool _isListening = false;
  final List buttons = [
    'C',
    'DEL',
    '%',
    '/',
    '7',
    '8',
    '9',
    '*',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '',
    '=',
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnable = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _onSpeechResult(result) {
    setState(() {
      userQuestion = result.recognizedWords;
    });
    setState(() {
      handleButtonTap('=');
    });
  }

  void _stopListenting() {
    _speechToText.stop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ListentingStop")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Text(
                  userQuestion,
                  style: userAnwser.isEmpty ? const TextStyle(fontSize: 45) : const TextStyle(fontSize: 35),
                ),
              ),
              Text(
                userAnwser,
                style: const TextStyle(fontSize: 50),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.17,
              ),
              Expanded(
                flex: 2,
                child: GridView.builder(
                  itemCount: buttons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                  itemBuilder: (context, index) {
                    if (index == buttons.length - 2) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            _speechToText.isListening ? _stopListenting() : _startListening();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.deepOrange[50]!,
                              child: Center(
                                child: Icon(color: Colors.deepOrangeAccent, _isListening ? Icons.mic : Icons.mic_none),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Button(
                          onButtonTap: () {
                            setState(() {
                              handleButtonTap(buttons[index]);
                            });
                          },
                          color: isOperator(buttons[index]) ? Colors.deepOrangeAccent : Colors.deepOrange[50]!,
                          textColor: isOperator(buttons[index]) ? Colors.deepPurple[50]! : Colors.deepOrangeAccent,
                          buttonText: buttons[index],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isOperator(String operator) {
    if (operator == "*" || operator == "/" || operator == "+" || operator == "-" || operator == "%" || operator == "=") {
      return true;
    }
    return false;
  }

  void handleButtonTap(String operator) {
    setState(() {
      if (operator == 'C') {
        userQuestion = '';
        userAnwser = '';
      } else if (operator == 'DEL') {
        if (userQuestion.isNotEmpty) {
          userQuestion = userQuestion.substring(0, userQuestion.length - 1);
        }
      } else if (operator == '=') {
        String finalQuestion = userQuestion;
        finalQuestion = finalQuestion.replaceAll('x', '*');
        Parser p = Parser();
        Expression exp = p.parse(finalQuestion);

        ContextModel cm = ContextModel();

        var eval = exp.evaluate(EvaluationType.REAL, cm);

        // Check if the result is a whole number
        if (eval == eval.toInt()) {
          // If it's a whole number, show it as an integer
          userAnwser = eval.toInt().toString();
        } else {
          // Otherwise, show it as a double
          userAnwser = eval.toString();
        }
      } else {
        userQuestion += operator;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}
