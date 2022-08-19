import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> sayiListesi = [];
  int sayi = 1;
  List<int> tiklanilanSayiListesi = [];
  DateTime baslamaZamani = DateTime.now();
  Duration gecenZaman = DateTime.now().difference(DateTime(1997));
  bool devam = true;
  String bestTime = "";

  @override
  void initState() {
    super.initState();

    listeyiDoldur();
    getBestTime().then((value) => bestTime = value ?? "");

    Timer.periodic(const Duration(milliseconds: 1), (Timer t) {
      if (devam == true) {
        setState(() {
          gecenZaman = DateTime.now().difference(baslamaZamani);
        });
      }
    });
  }

  @override
  void dispose() {
    devam = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("5x5 Normal"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      color: tiklanilanSayiListesi.contains(sayiListesi[index])
                          ? Colors.grey.shade500
                          : Colors.orangeAccent.shade400,
                      child: Center(
                        child: Text(
                          sayiListesi[index].toString(),
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    onTap: () {
                      if (sayiListesi[index] == sayi) {
                        if (!tiklanilanSayiListesi.contains(sayi)) {
                          setState(() {
                            tiklanilanSayiListesi.add(sayi);
                            sayi++;
                          });
                        }
                      }
                      if (sayi == 26) {
                        setState(() {
                          devam = false;
                        });
                        if (bestTime == "") {
                          setState(() {
                            bestTime = durationToString(gecenZaman);
                          });
                          saveBestTime(durationToString(gecenZaman));
                        } else if (stringToInt(durationToString(gecenZaman)) < stringToInt(bestTime)) {
                          setState(() {
                            bestTime = durationToString(gecenZaman);
                          });
                          saveBestTime(durationToString(gecenZaman));
                        }
                      }
                    },
                  );
                },
                itemCount: 25,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Center(
              child: Text(
                durationToString(gecenZaman),
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const Text(
                  "En İyi Skor",
                  style: TextStyle(fontSize: 30),
                ),
                Text(bestTime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void listeyiDoldur() {
    for (int i = 0;; i++) {
      var random = Random();
      int sayi = random.nextInt(25) + 1;

      if (!sayiListesi.contains(sayi)) {
        sayiListesi.add(sayi);
      }
      if (sayiListesi.length == 25) {
        break;
      }
    }
  }

  String durationToString(Duration d) {
    String part1 = d.toString().split(".")[0];
    String part2 = d.toString().split(".")[1];
    int part2Int = int.parse(part2) % 10;

    return "$part1.$part2Int";
  }

  int stringToInt(String s) {
    String hour = s.split(":")[0];
    String minute = s.split(":")[1];
    String second = s.split(":")[2].split(".")[0];
    String miliSecond = s.split(":")[2].split(".")[1];
    String total = hour + minute + second + miliSecond;
    return int.parse(total);
  }

  Future<String?> getBestTime() async {
    var preferences = await SharedPreferences.getInstance();
    return preferences.getString("bestTime");
  }

  saveBestTime(String s) async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setString("bestTime", s);
  }
}
