import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BMICalculator());
}

class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BMIHomePage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF302B63),
              Color(0xFF6A5AE0),
              Color(0xFF8E7CFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 65,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Calculate Your BMI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Know your body. Know your health.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),
            const SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BMIHomePage extends StatefulWidget {
  const BMIHomePage({super.key});

  @override
  State<BMIHomePage> createState() => _BMIHomePageState();
}

class _BMIHomePageState extends State<BMIHomePage> {
  final TextEditingController heightController =
      TextEditingController();

  final TextEditingController weightController =
      TextEditingController();

  String gender = '';
  String heightUnit = 'cm';
  String weightUnit = 'kg';

  double bmi = 0;
  String result = '';

  // =========================
  // BMI HISTORY
  // =========================

  List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('bmi_history') ?? [];

    setState(() {
      history = savedHistory.map((item) {
        final parts = item.split('||');

        return {
          'bmi': parts.length > 0 ? parts[0] : '',
          'result': parts.length > 1 ? parts[1] : '',
          'gender': parts.length > 2 ? parts[2] : '',
          'height': parts.length > 3 ? parts[3] : '',
          'weight': parts.length > 4 ? parts[4] : '',
          'date': parts.length > 5 ? parts[5] : '',
        };
      }).toList();
    });
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedHistory = history.map((item) {
      return [
        item['bmi'] ?? '',
        item['result'] ?? '',
        item['gender'] ?? '',
        item['height'] ?? '',
        item['weight'] ?? '',
        item['date'] ?? '',
      ].join('||');
    }).toList();

    await prefs.setStringList(
      'bmi_history',
      savedHistory,
    );
  }

  void addToHistory() {
    final now = DateTime.now();

    final date =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      history.insert(0, {
        'bmi': bmi.toStringAsFixed(2),
        'result': result,
        'gender': gender,
        'height': '${heightController.text} $heightUnit',
        'weight': '${weightController.text} $weightUnit',
        'date': date,
      });
    });

    saveHistory();
  }

  Future<void> deleteHistory(int index) async {
    setState(() {
      history.removeAt(index);
    });

    await saveHistory();
  }

  Future<void> clearHistory() async {
    setState(() {
      history.clear();
    });

    await saveHistory();
  }

  void showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BMI History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF302B63),
                          ),
                        ),
                        if (history.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              await clearHistory();
                              setSheetState(() {});
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: history.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No BMI history yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Calculate your BMI to save it here.',
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: history.length,
                              itemBuilder:
                                  (context, index) {
                                final item =
                                    history[index];

                                Color categoryColor;

                                if (item['result'] ==
                                    'Normal Weight') {
                                  categoryColor =
                                      Colors.green;
                                } else if (item['result'] ==
                                    'Underweight') {
                                  categoryColor =
                                      Colors.orange;
                                } else {
                                  categoryColor =
                                      Colors.red;
                                }

                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  padding:
                                      const EdgeInsets.all(
                                    15,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFF5F3FF,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(18),
                                    border:
                                        Border.all(
                                      color:
                                          categoryColor
                                              .withOpacity(
                                        0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            categoryColor
                                                .withOpacity(
                                          0.15,
                                        ),
                                        child: Icon(
                                          Icons
                                              .monitor_weight,
                                          color:
                                              categoryColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'BMI ${item['bmi']}',
                                              style:
                                                  const TextStyle(
                                                fontSize: 20,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                            Text(
                                              item['result'] ??
                                                  '',
                                              style:
                                                  TextStyle(
                                                color:
                                                    categoryColor,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              '${item['gender']} • ${item['height']} • ${item['weight']}',
                                            ),
                                            Text(
                                              item['date'] ??
                                                  '',
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            () async {
                                          await deleteHistory(
                                            index,
                                          );
                                          setSheetState(
                                            () {},
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // CALCULATE BMI
  // =========================

  void calculateBMI() {
    if (gender.isEmpty) {
      setState(() {
        result = 'Please select Male or Female';
        bmi = 0;
      });

      return;
    }

    double height =
        double.tryParse(heightController.text) ?? 0;

    double weight =
        double.tryParse(weightController.text) ?? 0;

    if (height <= 0 || weight <= 0) {
      setState(() {
        result =
            'Please enter correct height and weight';
        bmi = 0;
      });

      return;
    }

    double heightInMeter;

    if (heightUnit == 'cm') {
      heightInMeter = height / 100;
    } else if (heightUnit == 'inches') {
      heightInMeter = height * 0.0254;
    } else {
      heightInMeter = height * 0.3048;
    }

    double weightInKg;

    if (weightUnit == 'kg') {
      weightInKg = weight;
    } else {
      weightInKg = weight * 0.453592;
    }

    double calculatedBMI =
        weightInKg /
        (heightInMeter * heightInMeter);

    String category;

    if (calculatedBMI < 18.5) {
      category = 'Underweight';
    } else if (calculatedBMI < 25) {
      category = 'Normal Weight';
    } else if (calculatedBMI < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    setState(() {
      bmi = calculatedBMI;
      result = category;
    });

    addToHistory();
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    heightController.clear();
    weightController.clear();

    setState(() {
      gender = '';
      heightUnit = 'cm';
      weightUnit = 'kg';
      bmi = 0;
      result = '';
    });
  }

  // =========================
  // FEEDBACK TITLE
  // =========================

  String getFeedbackTitle() {
    if (result == 'Underweight') {
      return 'You may need to gain some weight 💪';
    } else if (result == 'Normal Weight') {
      return 'Great! You are healthy 😊';
    } else if (result == 'Overweight') {
      return 'Let\'s work towards a healthier weight 💪';
    } else if (result == 'Obese') {
      return 'Let\'s focus on improving your health ❤️';
    }

    return '';
  }

  // =========================
  // FEEDBACK MESSAGE
  // =========================

  String getFeedbackMessage() {
    if (result == 'Underweight') {
      return '''
Your BMI is below the normal range. Don't worry! 🌱

Try to gain weight gradually by eating nutritious,
energy-rich foods instead of relying on junk food.

🥛 Milk, curd and yogurt
🥚 Eggs
🥜 Nuts and peanut butter
🍌 Bananas
🥑 Avocado
🍚 Rice and whole grains
🥔 Potatoes and sweet potatoes
🐟 Fish, chicken or other protein-rich foods
🫘 Beans and pulses

Eat regular balanced meals and include healthy
protein and calorie sources in your diet.

If you are unexpectedly losing weight or finding it
difficult to gain weight, consider speaking with a
doctor or qualified dietitian.
''';
    }

    if (result == 'Normal Weight') {
      return '''
Excellent! 🎉😊

Your BMI is within the normal range.

Keep following a healthy lifestyle:

🥗 Eat a balanced diet
🍎 Include fruits and vegetables
🥚 Get enough protein
💧 Drink enough water
🏃 Exercise regularly
😴 Get sufficient sleep

Keep taking care of your health and maintain
your healthy habits! ❤️
''';
    }

    if (result == 'Overweight') {
      return '''
Your BMI is above the normal range. Don't feel bad! 🙂

Small and consistent lifestyle changes can help.

Try choosing:

🥗 More vegetables and salads
🍎 Fresh fruits
🥚 Eggs and lean protein
🐟 Fish or skinless chicken
🫘 Beans and pulses
🌾 Whole grains
🥛 Low-fat dairy options
💧 Plenty of water

Try to reduce:

🍟 Fried foods
🍔 Fast food
🥤 Sugary drinks
🍰 Excess sweets
🍕 Highly processed foods

Combine healthy eating with regular physical
activity and aim for gradual, sustainable weight loss.

If you have health conditions or are unsure how to
lose weight safely, consult a doctor or dietitian.
''';
    }

    if (result == 'Obese') {
      return '''
Your BMI is in the obesity range. ❤️

This does not define you, and you can improve your
health with gradual and consistent changes.

Choose more:

🥗 Vegetables and salads
🍎 Whole fruits
🥚 Eggs and lean protein
🐟 Fish or lean chicken
🫘 Beans and pulses
🌾 Whole grains
🥛 Low-fat dairy
💧 Water instead of sugary drinks

Try to limit:

🍟 Fried foods
🍔 Fast food
🥤 Sugary drinks
🍰 Excess sweets
🍕 Highly processed foods

Regular physical activity can also help improve
fitness and support healthy weight management.

Avoid crash diets or extreme weight-loss methods.
For obesity, it is especially useful to speak with
a doctor or qualified dietitian for an appropriate
and safe weight-management plan.
''';
    }

    return '';
  }

  // =========================
  // FEEDBACK COLORS
  // =========================

  List<Color> getFeedbackColors() {
    if (result == 'Underweight') {
      return [
        const Color(0xFFFFB74D),
        const Color(0xFFFF8A65),
      ];
    }

    if (result == 'Normal Weight') {
      return [
        const Color(0xFF43A047),
        const Color(0xFF66BB6A),
      ];
    }

    if (result == 'Overweight') {
      return [
        const Color(0xFFFFA726),
        const Color(0xFFFF7043),
      ];
    }

    if (result == 'Obese') {
      return [
        const Color(0xFFEF5350),
        const Color(0xFFD32F2F),
      ];
    }

    return [
      const Color(0xFF6A5AE0),
      const Color(0xFF8E7CFF),
    ];
  }

  // =========================
  // FEEDBACK ICON
  // =========================

  IconData getFeedbackIcon() {
    if (result == 'Underweight') {
      return Icons.restaurant;
    } else if (result == 'Normal Weight') {
      return Icons.sentiment_very_satisfied;
    } else if (result == 'Overweight') {
      return Icons.fitness_center;
    } else if (result == 'Obese') {
      return Icons.favorite;
    }

    return Icons.info;
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // =========================
              // HEADER
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  25,
                  35,
                  25,
                  30,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6A5AE0),
                      Color(0xFF8E7CFF),
                      Color(0xFFB39DDB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'BMI CALCULATOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Check your Body Mass Index',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // =========================
                    // GENDER
                    // =========================

                    const Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF302B63),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                gender = 'Male';
                              });
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 250,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    gender == 'Male'
                                        ? const LinearGradient(
                                            colors: [
                                              Color(
                                                0xFF42A5F5,
                                              ),
                                              Color(
                                                0xFF1976D2,
                                              ),
                                            ],
                                          )
                                        : null,
                                color: gender == 'Male'
                                    ? null
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                                border: Border.all(
                                  color:
                                      gender == 'Male'
                                          ? Colors.blue
                                          : Colors.grey
                                              .shade300,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.male,
                                    size: 48,
                                    color:
                                        gender == 'Male'
                                            ? Colors.white
                                            : Colors.blue,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'Male',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          gender == 'Male'
                                              ? Colors.white
                                              : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                gender = 'Female';
                              });
                            },
                            child: AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds: 250,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              decoration:
                                  BoxDecoration(
                                gradient:
                                    gender == 'Female'
                                        ? const LinearGradient(
                                            colors: [
                                              Color(
                                                0xFFEC407A,
                                              ),
                                              Color(
                                                0xFFD81B60,
                                              ),
                                            ],
                                          )
                                        : null,
                                color:
                                    gender == 'Female'
                                        ? null
                                        : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                                border: Border.all(
                                  color:
                                      gender == 'Female'
                                          ? Colors.pink
                                          : Colors.grey
                                              .shade300,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.female,
                                    size: 48,
                                    color:
                                        gender == 'Female'
                                            ? Colors.white
                                            : Colors.pink,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'Female',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          gender == 'Female'
                                              ? Colors.white
                                              : Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // HEIGHT
                    // =========================

                    Container(
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple
                                .withOpacity(0.08),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.height,
                                color:
                                    Color(0xFF6A5AE0),
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Height',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xFF302B63),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      heightController,
                                  keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        'Enter height',
                                    filled: true,
                                    fillColor:
                                        const Color(
                                      0xFFF5F3FF,
                                    ),
                                    prefixIcon:
                                        const Icon(
                                      Icons.straighten,
                                      color:
                                          Color(
                                        0xFF6A5AE0,
                                      ),
                                    ),
                                    border:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                      borderSide:
                                          BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFEDE7F6,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child:
                                    DropdownButton<String>(
                                  value: heightUnit,
                                  underline:
                                      const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'cm',
                                      child:
                                          Text('cm'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'inches',
                                      child:
                                          Text('inches'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'feet',
                                      child:
                                          Text('feet'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      heightUnit =
                                          value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // WEIGHT
                    // =========================

                    Container(
                      padding:
                          const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal
                                .withOpacity(0.08),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.monitor_weight,
                                color:
                                    Color(0xFF009688),
                                size: 28,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Weight',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xFF304D4A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      weightController,
                                  keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration:
                                      InputDecoration(
                                    hintText:
                                        'Enter weight',
                                    filled: true,
                                    fillColor:
                                        const Color(
                                      0xFFF5F3FF,
                                    ),
                                    prefixIcon:
                                        const Icon(
                                      Icons
                                          .monitor_weight,
                                      color:
                                          Color(
                                        0xFF009688,
                                      ),
                                    ),
                                    border:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                      borderSide:
                                          BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFE0F2F1,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child:
                                    DropdownButton<String>(
                                  value: weightUnit,
                                  underline:
                                      const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'kg',
                                      child:
                                          Text('kg'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'pounds',
                                      child:
                                          Text('pounds'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      weightUnit =
                                          value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // CALCULATE BUTTON
                    // =========================

                    SizedBox(
                      height: 58,
                      child: DecoratedBox(
                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFF6A5AE0),
                              Color(0xFF8E7CFF),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF6A5AE0,
                              ).withOpacity(0.3),
                              blurRadius: 12,
                              offset:
                                  const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: calculateBMI,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent,
                            shadowColor:
                                Colors.transparent,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calculate,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Calculate BMI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // =========================
                    // ERROR MESSAGE
                    // =========================

                    if (result ==
                            'Please select Male or Female' ||
                        result ==
                            'Please enter correct height and weight')
                      Container(
                        margin:
                            const EdgeInsets.only(top: 20),
                        padding:
                            const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                result,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // =========================
                    // BMI RESULT
                    // =========================

                    if (bmi > 0)
                      Container(
                        margin:
                            const EdgeInsets.only(
                          top: 20,
                        ),
                        padding:
                            const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFF302B63),
                              Color(0xFF6A5AE0),
                            ],
                            begin:
                                Alignment.topLeft,
                            end:
                                Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF6A5AE0,
                              ).withOpacity(0.25),
                              blurRadius: 15,
                              offset:
                                  const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Your BMI',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              bmi.toStringAsFixed(1),
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white
                                        .withOpacity(
                                  0.18,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(30),
                              ),
                              child: Text(
                                result,
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person,
                                  color:
                                      Colors.white70,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  'Gender: $gender',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // =========================
                    // HEALTH FEEDBACK
                    // =========================

                    if (bmi > 0)
                      Container(
                        margin:
                            const EdgeInsets.only(
                          top: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              LinearGradient(
                            colors:
                                getFeedbackColors(),
                            begin:
                                Alignment.topLeft,
                            end:
                                Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .white
                                          .withOpacity(
                                        0.20,
                                      ),
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child: Icon(
                                      getFeedbackIcon(),
                                      color:
                                          Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Text(
                                      getFeedbackTitle(),
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 19,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              Container(
                                width:
                                    double.infinity,
                                padding:
                                    const EdgeInsets
                                        .all(16),
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(
                                    0.15,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(16),
                                ),
                                child: Text(
                                  getFeedbackMessage(),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // =========================
                    // BMI HISTORY
                    // =========================

                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: showHistory,
                        icon:
                            const Icon(Icons.history),
                        label: Text(
                          history.isEmpty
                              ? 'BMI History'
                              : 'BMI History (${history.length})',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF6A5AE0),
                          side: const BorderSide(
                            color:
                                Color(0xFF6A5AE0),
                            width: 2,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // RESET
                    // =========================

                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: reset,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(
                            0xFF6A5AE0,
                          ),
                          side: const BorderSide(
                            color:
                                Color(0xFF6A5AE0),
                            width: 2,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Stay healthy • Stay fit • Stay happy ❤️',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}