import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setApplicationSwitcherDescription(
    ApplicationSwitcherDescription(
      label: 'Calculator',
      primaryColor: const Color.fromARGB(255, 255, 0, 0).value,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 0, 0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> calculationHistory = [];
  String expression = '0';
  String display = '0';
  void buttonPressed(String buttonText) {
    setState(() {
      if (expression.length == 30) {
        return;
      }
      buttonText = buttonText.replaceAll('xʸ', '^');
      String input = buttonText
          .replaceAll('÷', '/')
          .replaceAll('×', '*')
          .replaceAll(',', '.');
      if (expression == '0' && input == '-') {
        expression = input;
        display = input;
        return;
      }
      if('*/^'.contains(expression[expression.length - 1]) && input == '-') {
        expression += input;
        display += input;
        return;
      }

      if (expression.endsWith(input) && input == '.') {
        return;
      }

      if (expression == '0' && input == '.') {
        expression += input;
        display += buttonText;
        return;
      }

      if ('+-*/^'.contains(expression[expression.length - 1]) && input == '.') {
        expression += '0';
        display += '0';
      }

      if (('+-*/^'.contains(expression[expression.length - 1]) ||
              expression[expression.length - 1].contains('.')) &&
          '+-*/^'.contains(input)) {
        expression = expression.substring(0, expression.length - 1);
        display = display.substring(0, display.length - 1);
        if (expression == '') {
          expression = '0';
          display = '0';
        }
      }

      if (buttonText == '0' && expression == '0') {
        return;
      } else if (expression == '0' && !'+-*/^'.contains(input)) {
        expression = input;
        display = '';
      } else {
        expression += input;
      }

      display += buttonText;
    });
  }
  void clearDisplay() {
    setState(() {
      expression = '0';
      display = '0';
    });
  }
  void calculate() {
    Parser p = Parser();
    try {
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      String resultString = result.toString();
      if (resultString.endsWith('.0')) {
        resultString = resultString.substring(0, resultString.length - 2);
      }
      if (calculationHistory.length == 4) {
        calculationHistory.removeAt(0);
      }
      if (result.isNaN || result.isInfinite) {
        throw Exception();
      } else {
        String res = resultString.replaceAll('.', ',');
        calculationHistory.add("$display\n=$res");
        expression = resultString;
        display = res;
      }
    } catch (e) {
      calculationHistory.add("$display\n=Error");
      expression = '0';
      display = '0';
    }
    setState(() {});
  }
  void deleteCharacter() {
    setState(() {
      if (expression.isNotEmpty) {
        expression = expression.substring(0, expression.length - 1);
        if (expression == '') {
          expression = '0';
          display = '0';
        }
        else {
          display = display.substring(0, display.length - 1);
        }
      }
    });
  }
  void clearHistory() {
    setState(() {
      calculationHistory.clear();
    });
  }
  Widget buildButton(String buttonText, bool isOperator) {
    Color textColor = isOperator ? const Color.fromARGB(255, 192, 0, 0) : Colors.grey;
    Color foregroundColor = isOperator ? const Color.fromARGB(255, 112, 0, 0) : const Color.fromARGB(255, 64, 64, 64);
    Color backgroundColor = buttonText == '=' ? const Color.fromARGB(128, 255, 16, 16) : Colors.transparent;
    if (buttonText == '='){
      textColor = Colors.white;
      foregroundColor = const Color.fromARGB(255, 255, 0, 0);
    }
    return SizedBox(
      width: 64.0,
      height: 64.0,
      child: ElevatedButton(
        onPressed: () {
          if (buttonText == 'C') {
            clearDisplay();
          } else if (buttonText == '⌫') {
            deleteCharacter();
          } else if (buttonText == 'AC') {
            clearHistory();
          } else if (buttonText == '=') {
            calculate();
          } else {
            buttonPressed(buttonText);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.all(0),
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 28.0,
              overflow: TextOverflow.clip,
            ).copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/appicon.svg',
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(Color.fromARGB(255, 255, 0, 0), BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 0, 0),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(128, 255, 0, 0),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 75,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: ListView.builder(
                  itemExtent: 60.0,
                  reverse: true,
                  itemCount: calculationHistory.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = calculationHistory.reversed.toList()[index];
                    return ListTile(
                      title: Text(
                        item,
                        style: const TextStyle(color: Color.fromARGB(86, 255, 255, 255)),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 25,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.bottomRight,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(128, 255, 0, 0),
                      width: 1.0,
                    ),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    display,
                    style: const TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildButton('C', true),
                      buildButton('⌫', true),
                      buildButton('xʸ', true),
                      buildButton('÷', true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildButton('7', false),
                      buildButton('8', false),
                      buildButton('9', false),
                      buildButton('×', true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildButton('4', false),
                      buildButton('5', false),
                      buildButton('6', false),
                      buildButton('-', true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildButton('1', false),
                      buildButton('2', false),
                      buildButton('3', false),
                      buildButton('+', true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildButton('AC', true),
                      buildButton('0', false),
                      buildButton(',', false),
                      buildButton('=', true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}