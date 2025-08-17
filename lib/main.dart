import 'dart:async'; // IMPORTANTE para usar Timer
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Funções para multiplicadores
double vitimaerradas(double a) {
  double x = 1;
  if (a == 1) x = 1.1;
  if (a == 2) x = 1.21;
  if (a == 3) x = 1.331;
  return x;
}

double vitima(double a) {
  double x = 1;
  if (a == 1) x = 1.3;
  if (a == 2) x = 1.69;
  if (a == 3) x = 2.197;
  return x;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int gangorra = 0;
  int gaps = 0;
  int intersecao_ou_beco_sem_saida = 0;
  int obstaculo = 0;
  int rampa = 0;
  int lombadas = 0;
  int passagem = 0;
  int chegada = 0;
  int ladrilho1 = 0;
  int ladrilho2 = 0;
  bool ladrilhoum = false;
  bool ladrilhodois = false;
  int quantfalha = 0;
  int ladrilhoP = 0;
  int ladrilhoS = 0;
  int ladrilhoT = 0;
  double vitimacerta = 1;
  double vitimaerrada = 1;

  // Controllers para os TextFields
  final TextEditingController gapsController = TextEditingController();
  final TextEditingController gangorraController = TextEditingController();
  final TextEditingController intersecaoController = TextEditingController();
  final TextEditingController obstaculoController = TextEditingController();
  final TextEditingController rampaController = TextEditingController();
  final TextEditingController lombadasController = TextEditingController();
  final TextEditingController ladrilhoPController = TextEditingController();
  final TextEditingController ladrilhoSController = TextEditingController();
  final TextEditingController ladrilhoTController = TextEditingController();
  final TextEditingController falhasController = TextEditingController();

  int timer = 0; // tempo em segundos
  Timer? cronometro; // referência do timer

  double bonusExtra = 0;  // slider 1 multiplicador
  double bonusExtra2 = 0; // slider 2 multiplicador

  @override
  Widget build(BuildContext context) {
    int baseTotal = gangorra +
        gaps +
        intersecao_ou_beco_sem_saida +
        obstaculo +
        rampa +
        lombadas +
        passagem +
        chegada +
        ladrilho1 +
        ladrilhoP +
        ladrilhoS +
        ladrilhoT +
        (ladrilhodois ? (60 - (quantfalha * 5)) : 0);

    double total = (baseTotal * vitimacerta) * vitimaerrada;
    int total1 = total.floorToDouble().toInt();

    // Converter segundos para mm:ss
    String formatTime(int seconds) {
      int min = seconds ~/ 60;
      int sec = seconds % 60;
      return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade700,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("OBR SCORER",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("⏲️ ${formatTime(timer)}",
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Text(" $total1 Pts",
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                blocoCheckbox(
                  label: "Ladrilho Superado de primeira tentativa",
                  value: ladrilhoum,
                  onChanged: (val) {
                    setState(() {
                      ladrilhoum = val;
                      ladrilho1 = ladrilhoum ? 5 : 0;
                    });
                  },
                ),

                blocoCheckbox(
                  label: "Linha de chegada",
                  value: ladrilhodois,
                  onChanged: (val) {
                    setState(() {
                      ladrilhodois = val;
                      ladrilho2 = ladrilhodois ? 60 : 0;
                    });
                  },
                ),

                blocoCampo("Quantidade ladrilhos com gaps Superados",gapsController, (value) {
                  setState(() {
                    gaps = 10 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Gangorras Superados", gangorraController, (value) {
                  setState(() {
                    gangorra = 20 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Interseção ou Beco sem Saída Superados", intersecaoController, (value) {
                  setState(() {
                    intersecao_ou_beco_sem_saida = 10 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Obstáculos Superados", obstaculoController,(value) {
                  setState(() {
                    obstaculo = 20 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Ladrilhos com Rampa Superados",rampaController, (value) {
                  setState(() {
                    rampa = 10 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Ladrilhos com Lombada Superados",lombadasController, (value) {
                  setState(() {
                    lombadas = 10 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Ladrilhos Superados na primeira tentativa",ladrilhoPController,(value) {
                  setState(() {
                    ladrilhoP = 5 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Ladrilhos Superados na segunda tentativa",ladrilhoSController,(value) {
                  setState(() {
                    ladrilhoS = 3 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade Ladrilhos Superados na terceira tentativa",ladrilhoTController,(value) {
                  setState(() {
                    ladrilhoT = 1 * (int.tryParse(value) ?? 0);
                  });
                }),
                blocoCampo("Quantidade de falhas",falhasController, (value) {
                  setState(() {
                    quantfalha = int.tryParse(value) ?? 0;
                  });
                }),

                const SizedBox(height: 20),

                // Slider corrigido para vítimas certas
                blocoSlider(
                  label: "Quantidade de vítimas na área certa",
                  value: bonusExtra,
                  onChanged: (val) {
                    setState(() {
                      bonusExtra = val;
                      vitimacerta = vitima(val);
                    });
                  },
                ),

                // Slider corrigido para vítimas erradas
                blocoSlider(
                  label: "Quantidade de vítimas na área ERRADA",
                  value: bonusExtra2,
                  onChanged: (val1) {
                    setState(() {
                      bonusExtra2 = val1;
                      vitimaerrada = vitimaerradas(val1);
                    });
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        cronometro?.cancel();
                        setState(() { timer = 0; });
                        cronometro = Timer.periodic(const Duration(seconds: 1), (t) {
                          if (timer < 300) {
                            setState(() { timer++; });
                          } else {
                            t.cancel();
                          }
                        });
                      },
                      child: const Text("Iniciar Timer"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        cronometro?.cancel();
                        setState(() { timer = 0; });
                      },
                      child: const Text("Reset Timer"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          gangorra = 0;
                          gaps = 0;
                          intersecao_ou_beco_sem_saida = 0;
                          obstaculo = 0;
                          rampa = 0;
                          lombadas = 0;
                          passagem = 0;
                          chegada = 0;
                          ladrilho1 = 0;
                          ladrilho2 = 0;
                          ladrilhoum = false;
                          ladrilhodois = false;
                          quantfalha = 0;
                          ladrilhoP = 0;
                          ladrilhoS = 0;
                          ladrilhoT = 0;
                          bonusExtra = 0;
                          bonusExtra2 = 0;
                          vitimacerta = 0;
                          vitimaerrada = 0;
                          gapsController.clear();
                          gangorraController.clear();
                          intersecaoController.clear();
                          obstaculoController.clear();
                          rampaController.clear();
                          lombadasController.clear();
                          ladrilhoPController.clear();
                          ladrilhoSController.clear();
                          ladrilhoTController.clear();
                          falhasController.clear();
                        });
                      },
                      child: const Text("Limpar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget blocoCampo(String label, TextEditingController controller, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  Widget blocoCheckbox({required String label, required bool value, required Function(bool) onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val ?? false),
            checkColor: Colors.white,
            activeColor: Colors.red.shade700,
          ),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Widget blocoSlider({required String label, required double value, required Function(double) onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value,
            min: 0,
            max: 3,
            divisions: 3,
            label: (value.round()).toString(),
            activeColor: Colors.red.shade700,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
