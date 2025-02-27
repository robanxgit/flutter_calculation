import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CalculatorApp());
}

// Main entry point for the calculator application
class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(), // Navigate to CalculatorScreen
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = "0"; // Holds the display value
  double _firstOperand = 0; // Stores the first number in an operation
  String? _operator; // Stores the operator (+, -, *, /)
  bool _isNewEntry = true; // Flag to check if new input starts

  @override
  void initState() {
    super.initState();
    _loadLastResult(); // Load last saved result
  }

  // Load the last result from shared preferences
  void _loadLastResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _display = prefs.getString("lastResult") ?? "0";
    });
  }

  // Save the last result to shared preferences
  void _saveLastResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("lastResult", _display);
  }

  // Handle number button presses
  void _onDigitPress(String digit) {
    setState(() {
      if (_display.length >= 8) return; // Limit display to 8 digits
      if (_isNewEntry) {
        _display = digit;
        _isNewEntry = false;
      } else {
        _display += digit;
      }
    });
  }

  // Handle operator button presses
  void _onOperatorPress(String operator) {
    setState(() {
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = operator;
      _isNewEntry = true;
    });
  }

  // Calculate the result when '=' is pressed
  void _onEqualsPress() {
    setState(() {
      if (_operator == null) return;
      double secondOperand = double.tryParse(_display) ?? 0;
      double result = 0;
      try {
        switch (_operator) {
          case '+':
            result = _firstOperand + secondOperand;
            break;
          case '-':
            result = _firstOperand - secondOperand;
            break;
          case '*':
            result = _firstOperand * secondOperand;
            break;
          case '/':
            if (secondOperand == 0) {
              _display = "ERROR"; // Prevent division by zero
              return;
            }
            result = _firstOperand / secondOperand;
            break;
        }
        _display = result.toStringAsFixed(2);
        if (_display.length > 8) _display = "OVERFLOW"; // Prevent overflow errors
      } catch (e) {
        _display = "ERROR";
      }
      _operator = null;
      _isNewEntry = true;
      _saveLastResult(); // Save the latest result
    });
  }

  // Clear only the current entry
  void _onClearEntry() {
    setState(() {
      _display = "0";
      _isNewEntry = true;
    });
  }

  // Clear everything and reset
  void _onClear() {
    setState(() {
      _display = "0";
      _firstOperand = 0;
      _operator = null;
      _isNewEntry = true;
      _saveLastResult();
    });
  }

  // Function to create calculator buttons
  Widget _buildButton(String text, {VoidCallback? onPressed}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display Screen
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(16),
            child: Text(
              _display,
              style: TextStyle(fontSize: 48, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: Divider()),
          // Buttons Layout
          Column(
            children: [
              Row(
                children: [
                  _buildButton("1", onPressed: () => _onDigitPress("1")),
                  _buildButton("2", onPressed: () => _onDigitPress("2")),
                  _buildButton("3", onPressed: () => _onDigitPress("3")),
                  _buildButton("+", onPressed: () => _onOperatorPress("+")),
                ],
              ),
              Row(
                children: [
                  _buildButton("4", onPressed: () => _onDigitPress("4")),
                  _buildButton("5", onPressed: () => _onDigitPress("5")),
                  _buildButton("6", onPressed: () => _onDigitPress("6")),
                  _buildButton("-", onPressed: () => _onOperatorPress("-")),
                ],
              ),
              Row(
                children: [
                  _buildButton("7", onPressed: () => _onDigitPress("7")),
                  _buildButton("8", onPressed: () => _onDigitPress("8")),
                  _buildButton("9", onPressed: () => _onDigitPress("9")),
                  _buildButton("*", onPressed: () => _onOperatorPress("*")),
                ],
              ),
              Row(
                children: [
                  _buildButton("CE", onPressed: _onClearEntry),
                  _buildButton("0", onPressed: () => _onDigitPress("0")),
                  _buildButton("C", onPressed: _onClear),
                  _buildButton("/", onPressed: () => _onOperatorPress("/")),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildButton("=", onPressed: _onEqualsPress)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
