import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: ColorGame()));

class ColorGame extends StatefulWidget {
  @override
  _ColorGameState createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {
  final List<Color> colorList = [
    Colors.grey,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.red
  ];
  List<int> userColorIndexes = [0, 0, 0, 0];
  List<int> correctSequence = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    generateSequence();
  }

  void generateSequence() {
    final rand = Random();
    correctSequence = List.generate(4, (_) => rand.nextInt(4) + 1);
    print('Sequenza corretta (debug): $correctSequence');
  }

  void changeColor(int index) {
    setState(() {
      userColorIndexes[index] =
          (userColorIndexes[index] + 1) % colorList.length;
      message = '';
    });
  }

  void checkSequence() {
    bool correct = true;
    for (int i = 0; i < 4; i++) {
      if (userColorIndexes[i] != correctSequence[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      if (correct) {
        message = 'BEA!';
        userColorIndexes = [0, 0, 0, 0];
        generateSequence();
      } else {
        message = 'Sequenza non corretta';
        userColorIndexes = [0, 0, 0, 0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indovina il colore')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Indovina il colore', style: TextStyle(fontSize: 24)),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return GestureDetector(
                onTap: () => changeColor(i),
                child: Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorList[userColorIndexes[i]],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 80),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5, right: 5),
              child: ElevatedButton(
                onPressed: checkSequence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  fixedSize: Size(60, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('?', style: TextStyle(fontSize: 24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
