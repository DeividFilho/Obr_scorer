import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp1());
}

// Funções para multiplicadores (NÃO MEXIDAS)
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

// lista global
List<Map<String, dynamic>> historicoResultados = [];
void salvarResultado(int pontos, int tempo) {
  historicoResultados.add({
    'pontos': pontos,
    'tempo': tempo,
    'data': DateTime.now(),
  });
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo Navegação',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Pontos
  int gangorra = 0,
      gaps = 0,
      intersecao = 0,
      obstaculo = 0,
      rampa = 0,
      lombadas = 0;
  int ladrilho1 = 0, ladrilhoP = 0, ladrilhoS = 0, ladrilhoT = 0;
  bool ladrilhoum = false, ladrilhodois = false;
  int quantfalha = 0;

  // Multiplicadores de vítimas (NÃO MEXIDOS)
  double vitimacerta = 1, vitimaerrada = 1;
  double bonusExtra = 0, bonusExtra2 = 0;

  // Timer
  int timer = 0;
  Timer? cronometro;

  // Controllers agrupados
  final List<TextEditingController> controllers =
  List.generate(8, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    // Cálculo do total
    int baseTotal = gangorra +
        gaps +
        intersecao +
        obstaculo +
        rampa +
        lombadas +
        ladrilho1 +
        ladrilhoP +
        ladrilhoS +
        ladrilhoT +
        (ladrilhodois ? (60 - (quantfalha * 5)) : 0);

    double total = (baseTotal * vitimacerta) * vitimaerrada;
    int total1 = total.floor();

    // Formatar tempo mm:ss
    String formatTime(int s) =>
        "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";

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
                // Ladrilho primeira tentativa
                blocoCheckbox(
                  label: "Ladrilho Superado de primeira tentativa",
                  value: ladrilhoum,
                  onChanged: (val) => setState(() {
                    ladrilhoum = val;
                    ladrilho1 = val ? 5 : 0;
                  }),
                ),

                // Linha de chegada (NÃO MEXIDA)
                blocoCheckbox(
                  label: "Linha de chegada",
                  value: ladrilhodois,
                  onChanged: (val) => setState(() => ladrilhodois = val),
                ),

                blocoCampo(
                    "Qtd. ladrilhos com gaps",
                    controllers[0],
                        (v) =>
                        setState(() => gaps = 10 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. Gangorras",
                    controllers[1],
                        (v) =>
                        setState(() => gangorra = 20 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. Interseções ou Becos",
                    controllers[2],
                        (v) =>
                        setState(() => intersecao = 10 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. Obstáculos",
                    controllers[3],
                        (v) =>
                        setState(() => obstaculo = 20 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. Ladrilhos com rampa",
                    controllers[4],
                        (v) =>
                        setState(() => rampa = 10 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. Ladrilhos com lombada",
                    controllers[5],
                        (v) =>
                        setState(() => lombadas = 10 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. ladrilhos 1ª tentativa",
                    controllers[6],
                        (v) =>
                        setState(() => ladrilhoP = 5 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. ladrilhos 2ª tentativa",
                    controllers[7],
                        (v) =>
                        setState(() => ladrilhoS = 3 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Qtd. ladrilhos 3ª tentativa",
                    TextEditingController(),
                        (v) => setState(() => ladrilhoT = 1 * (int.tryParse(v) ?? 0))),
                blocoCampo(
                    "Quantidade de falhas",
                    TextEditingController(),
                        (v) => setState(() => quantfalha = int.tryParse(v) ?? 0)),

                const SizedBox(height: 20),

                // Sliders vítimas (NÃO MEXIDOS)
                blocoSlider(
                  label: "Quantidade de vítimas na área certa",
                  value: bonusExtra,
                  onChanged: (val) => setState(() {
                    bonusExtra = val;
                    vitimacerta = vitima(val);
                  }),
                ),
                blocoSlider(
                  label: "Quantidade de vítimas na área ERRADA",
                  value: bonusExtra2,
                  onChanged: (val) => setState(() {
                    bonusExtra2 = val;
                    vitimaerrada = vitimaerradas(val);
                  }),
                ),

                const SizedBox(height: 20),

                // Botões
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    botao("Iniciar Timer", Colors.green, () {
                      cronometro?.cancel();
                      setState(() => timer = 0);
                      cronometro = Timer.periodic(const Duration(seconds: 1), (t) {
                        if (timer < 300) setState(() => timer++);
                        else t.cancel();
                      });
                    }),
                    botao("Reset Timer", Colors.red, () {
                      cronometro?.cancel();
                      setState(() => timer = 0);
                    }),
                    botao("Limpar", Colors.red, () {
                      cronometro?.cancel();
                      setState(() {
                        gangorra = gaps = intersecao = obstaculo = rampa = lombadas = 0;
                        ladrilho1 = ladrilhoP = ladrilhoS = ladrilhoT = quantfalha = 0;
                        ladrilhoum = ladrilhodois = false;
                        bonusExtra = bonusExtra2 = 0;
                        vitimacerta = vitimaerrada = 1;
                        for (var c in controllers) c.clear();
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),


        bottomNavigationBar: BottomAppBar(
          color: Colors.red.shade700,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoricoPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.checklist),
                color: Colors.white,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.save),
                color: Colors.white,
                onPressed: () {
                  salvarResultado(total1, timer);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Resultado salvo!")));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget blocoCampo(
      String label, TextEditingController controller, Function(String) onChanged) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label, border: InputBorder.none),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      );

  Widget blocoCheckbox(
      {required String label,
        required bool value,
        required Function(bool) onChanged}) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
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

  Widget blocoSlider(
      {required String label,
        required double value,
        required Function(double) onChanged}) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            Slider(
              value: value,
              min: 0,
              max: 3,
              divisions: 3,
              label: value.round().toString(),
              activeColor: Colors.red.shade700,
              onChanged: onChanged,
            ),
          ],
        ),
      );

  Widget botao(String texto, Color cor, VoidCallback onPressed) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: cor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    onPressed: onPressed,
    child: Text(texto),
  );
}

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  String formatTime(int s) =>
      "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico"),
        backgroundColor: Colors.red.shade700,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red.shade700,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.checklist),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              historicoResultados.isEmpty
                  ? const Center(child: Text("Nenhum resultado registrado."))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historicoResultados.length,
                itemBuilder: (context, index) {
                  final r = historicoResultados[index];
                  return ListTile(
                    title: Text("Pontos: ${r['pontos']}"),
                    subtitle:
                    Text("Tempo: ${formatTime(r['tempo'])} - ${r['data']}"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
