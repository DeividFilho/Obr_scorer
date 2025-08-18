import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp1());
}

// Funções otimizadas
double vitimaerradas(double a) {
  const valores = {1: 1.1, 2: 1.21, 3: 1.331};
  return valores[a] ?? 1;
}

double vitima(double a) {
  const valores = {1: 1.3, 2: 1.69, 3: 2.197};
  return valores[a] ?? 1;
}

// Histórico
List<Map<String, dynamic>> historicoResultados = [];

Future<void> salvarResultado(int pontos, int tempo) async {
  historicoResultados.add({
    'pontos': pontos,
    'tempo': tempo,
    'data': DateTime.now().toString(),
  });
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('historico', jsonEncode(historicoResultados));
}

Future<void> carregarHistorico() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('historico');
  if (jsonString != null) {
    historicoResultados =
        (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'OBR SCORER',
      home: HomePage(),
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

  // Multiplicadores
  double vitimacerta = 1, vitimaerrada = 1;
  double bonusExtra = 0, bonusExtra2 = 0;

  // Timer
  int timer = 0;
  Timer? cronometro;

  // Controllers (10 campos)
  final controllers = List.generate(10, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  // --- Getters otimizados ---
  int get baseTotal =>
      gangorra +
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

  int get total => (baseTotal * vitimacerta * vitimaerrada).floor();

  String formatTime(int s) =>
      "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";

  void resetAll() {
    cronometro?.cancel();
    setState(() {
      gangorra = gaps = intersecao = obstaculo = rampa = lombadas = 0;
      ladrilho1 = ladrilhoP = ladrilhoS = ladrilhoT = quantfalha = 0;
      ladrilhoum = ladrilhodois = false;
      bonusExtra = bonusExtra2 = 0;
      vitimacerta = vitimaerrada = 1;
      for (var c in controllers) c.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("OBR SCORER",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("⏲️ ${formatTime(timer)}",
                style:
                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            Text(" $total Pts",
                style:
                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // Checkboxes
          blocoCheckbox(
            label: "Ladrilho Superado de primeira tentativa",
            value: ladrilhoum,
            onChanged: (val) =>
                setState(() => {ladrilhoum = val, ladrilho1 = val ? 5 : 0}),
          ),
          blocoCheckbox(
            label: "Linha de chegada",
            value: ladrilhodois,
            onChanged: (val) => setState(() => ladrilhodois = val),
          ),

          // Campos de texto
          blocoCampo("Qtd. ladrilhos com gaps", controllers[0],
                  (v) => setState(() => gaps = 10 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. Gangorras", controllers[1],
                  (v) => setState(() => gangorra = 20 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. Interseções ou Becos", controllers[2],
                  (v) => setState(() => intersecao = 10 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. Obstáculos", controllers[3],
                  (v) => setState(() => obstaculo = 20 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. Ladrilhos com rampa", controllers[4],
                  (v) => setState(() => rampa = 10 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. Ladrilhos com lombada", controllers[5],
                  (v) => setState(() => lombadas = 10 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. ladrilhos 1ª tentativa", controllers[6],
                  (v) => setState(() => ladrilhoP = 5 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. ladrilhos 2ª tentativa", controllers[7],
                  (v) => setState(() => ladrilhoS = 3 * (int.tryParse(v) ?? 0))),
          blocoCampo("Qtd. ladrilhos 3ª tentativa", controllers[8],
                  (v) => setState(() => ladrilhoT = 1 * (int.tryParse(v) ?? 0))),
          blocoCampo("Quantidade de falhas", controllers[9],
                  (v) => setState(() => quantfalha = int.tryParse(v) ?? 0)),

          const SizedBox(height: 20),

          // Sliders
          blocoSlider(
            label: "Quantidade de vítimas na área certa",
            value: bonusExtra,
            onChanged: (val) =>
                setState(() => {bonusExtra = val, vitimacerta = vitima(val)}),
          ),
          blocoSlider(
            label: "Quantidade de vítimas na área ERRADA",
            value: bonusExtra2,
            onChanged: (val) =>
                setState(() => {bonusExtra2 = val, vitimaerrada = vitimaerradas(val)}),
          ),

          const SizedBox(height: 20),

          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              botao("Reset Timer", Colors.red,
                      () => setState(() => {cronometro?.cancel(), timer = 0})),
              botao("Limpar", Colors.red, resetAll),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
              child: Text("Inspiração e apoio: Murilo Barreto e FLL SCORER"))
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red.shade700,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.history),
              color: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoricoPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.save),
              color: Colors.white,
              onPressed: () async {
                await salvarResultado(total, timer);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Resultado salvo!"),backgroundColor: Colors.red,));
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              color: Colors.white,
              onPressed: () {
                cronometro?.cancel();
                setState(() => timer = 0);
                cronometro = Timer.periodic(const Duration(seconds: 1), (t) {
                  if (timer < 300) {
                    setState(() => timer++);
                  } else {
                    t.cancel();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.pause),
              color: Colors.white,
              onPressed: () => cronometro?.cancel(),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets reutilizáveis
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
      body: historicoResultados.isEmpty
          ? const Center(child: Text("Nenhum resultado registrado."))
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: historicoResultados.length,
        itemBuilder: (context, index) {
          final r = historicoResultados[index];
          return ListTile(
            title: Text("Pontos: ${r['pontos']}"),
            subtitle: Text(
                "Tempo: ${formatTime(r['tempo'])} - ${r['data']}"),
          );
        },
      ),
    );
  }
}
