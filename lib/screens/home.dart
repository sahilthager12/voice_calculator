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
      userQuestion = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final List buttons = [
      'C',
      'DEL',
      '%',
      '/',
      '9',
      '8',
      '7',
      '*',
      '6',
      '5',
      '4',
      '-',
      '3',
      '2',
      '1',
      '+',
      '0',
      '.',
      '',
      '=',
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        userQuestion,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                    Text(
                      userAnwser,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
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
                            _startListening();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.deepOrange[50],
                              child: const Center(
                                child: Icon(
                                  Icons.mic,
                                  color: Colors.deepOrangeAccent,
                                ),
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

  void handleButtonTap(String buttonText) {
    if (buttonText == 'C') {
      userQuestion = '';
      userAnwser = '';
    } else if (buttonText == 'DEL') {
      if (userQuestion.isNotEmpty) {
        userQuestion = userQuestion.substring(0, userQuestion.length - 1);
      }
    } else if (buttonText == '=') {
      String finalQuestion = userQuestion;
      finalQuestion = finalQuestion.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalQuestion);

      ContextModel cm = ContextModel();

      var eval = exp.evaluate(EvaluationType.REAL, cm);
      userAnwser = eval.toString();
    } else {
      userQuestion += buttonText;
    }
  }
}
