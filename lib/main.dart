import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SelectedMotoProvider(),
      child: const MyApp(),
    ),
  );
}

class Moto {
  final String marcaModelo;
  final double fuelTankLiters;
  final double consumptionL100;

  Moto({
    required this.marcaModelo,
    required this.fuelTankLiters,
    required this.consumptionL100,
  });
}

final List<Moto> motos = [
  Moto(marcaModelo: 'Honda PCX 125', fuelTankLiters: 8.0, consumptionL100: 2.1),
  Moto(marcaModelo: 'Yamaha NMAX 125', fuelTankLiters: 7.1, consumptionL100: 2.2),
  Moto(marcaModelo: 'Kymco Agility City 125', fuelTankLiters: 7.0, consumptionL100: 2.5),
  Moto(marcaModelo: 'Piaggio Liberty 125', fuelTankLiters: 6.0, consumptionL100: 2.3),
  Moto(marcaModelo: 'Sym Symphony 125', fuelTankLiters: 5.5, consumptionL100: 2.4),
  Moto(marcaModelo: 'Vespa Primavera 125', fuelTankLiters: 8.0, consumptionL100: 2.8),
  Moto(marcaModelo: 'Kawasaki J125', fuelTankLiters: 11.0, consumptionL100: 3.5),
  Moto(marcaModelo: 'Peugeot Pulsion 125', fuelTankLiters: 12.0, consumptionL100: 3.0),
];

class SelectedMotoProvider extends ChangeNotifier {
  Moto selected = motos.first;
  void setSelected(Moto m) {
    selected = m;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const PrimeraPagina());
  }
}
class PrimeraPagina extends StatefulWidget {
  const PrimeraPagina({super.key});

  @override
  State<PrimeraPagina> createState() => _PrimeraPaginaState();
}

class _PrimeraPaginaState extends State<PrimeraPagina> {
  late Moto dropdownValue;

  @override
  void initState() {
    super.initState();

    // 🔥 Quan entrem a la pantalla, agafem la moto guardada al Provider
    final provider = Provider.of<SelectedMotoProvider>(context, listen: false);
    dropdownValue = provider.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MotosApp")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<Moto>(
              value: dropdownValue,
              isExpanded: true,
              items: motos.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.marcaModelo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => dropdownValue = value!);

                // 🔥 Actualitzem al provider perquè quedi guardat
                Provider.of<SelectedMotoProvider>(context, listen: false)
                    .setSelected(value!);
              },
            ),

            const SizedBox(height: 10),

            Text(
              "Moto seleccionada: ${dropdownValue.marcaModelo}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SegonaPagina()),
                );
              },
              child: const Text("Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}


class SegonaPagina extends StatefulWidget {
  const SegonaPagina({super.key});

  @override
  State<SegonaPagina> createState() => _SegonaPaginaState();
}

class _SegonaPaginaState extends State<SegonaPagina> {
  final TextEditingController kmOmplir = TextEditingController();
  final TextEditingController kmActual = TextEditingController();

  String resultat = "";

  double autonomia(Moto m) {
    return (m.fuelTankLiters / m.consumptionL100) * 100;
  }

  double calcularRestant(Moto m, double kmIni, double kmAct) {
    final recorregut = kmAct - kmIni;
    if (recorregut < 0) return autonomia(m);

    final consumits = (recorregut * m.consumptionL100) / 100;
    final restants = m.fuelTankLiters - consumits;

    if (restants <= 0) return 0;
    return (restants / m.consumptionL100) * 100;
  }

  void calcular(Moto m) {
    final ini = double.tryParse(kmOmplir.text);
    final act = double.tryParse(kmActual.text);

    if (ini == null || act == null) {
      setState(() => resultat = "Introdueix números vàlids.");
      return;
    }

    final total = autonomia(m);
    final restant = calcularRestant(m, ini, act);

    setState(() {
      resultat =
          "Moto: ${m.marcaModelo}\nAutonomia total: ${total.toStringAsFixed(1)} km\nQueden: ${restant.toStringAsFixed(1)} km";
    });
  }

  @override
  Widget build(BuildContext context) {
    final moto = Provider.of<SelectedMotoProvider>(context).selected;

    return Scaffold(
      appBar: AppBar(title: const Text("MotosApp")),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Model: ${moto.marcaModelo}"),
            Text("Dipòsit: ${moto.fuelTankLiters} L"),
            Text("Consum: ${moto.consumptionL100} L/100km"),
            const SizedBox(height: 10),
            TextField(
              controller: kmOmplir,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Km quan vas omplir"),
            ),
            TextField(
              controller: kmActual,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Km actuals"),
            ),
            ElevatedButton(
              onPressed: () => calcular(moto),
              child: const Text("Calcular"),
            ),
            const SizedBox(height: 20),
            Text(resultat),
          ],
        ),
      ),
    );
  }
}
