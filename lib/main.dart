import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animal.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Zoo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AnimalListPage(),
    );
  }
}

class AnimalListPage extends StatefulWidget {
  const AnimalListPage({super.key});

  @override
  State<AnimalListPage> createState() => _AnimalListPageState();
}

class _AnimalListPageState extends State<AnimalListPage> {
  List<Animal> animals = [];
  bool isLoading = true;
  bool showList = false;

  @override
  void initState() {
    super.initState();
    loadAnimals();
  }

  Future<void> loadAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('zoo_animals');
    if (cached != null) {
      final List<dynamic> jsonList = json.decode(cached);
      setState(() {
        animals = jsonList.map((e) => Animal.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      final jsonString = await rootBundle.loadString('lib/zoo_animals.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      await prefs.setString('zoo_animals', jsonString);
      setState(() {
        animals = jsonList.map((e) => Animal.fromJson(e)).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!showList) {
      return Scaffold(
        appBar: AppBar(title: const Text('Atlas Zoo')),
        body: Center(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => showList = true),
            icon: const Icon(Icons.pets, size: 32),
            label: const Text('Pokaż zwierzęta', style: TextStyle(fontSize: 24)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Zoo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => showList = false),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemCount: animals.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final animal = animals[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(animal.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(animal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(animal.species),
              trailing: const Icon(Icons.info_outline),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(animal.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gatunek: ${animal.species}'),
                      Text('Wiek: ${animal.age}'),
                      Text('Waga: ${animal.weight} kg'),
                      Text('Pochodzenie: ${animal.origin}'),
                      Text('Dieta: ${animal.diet}'),
                      Text('Siedlisko: ${animal.habitat}'),
                      Text('Zagrożony: ${animal.isEndangered ? "Tak" : "Nie"}'),
                      Text('Sekcja zoo: ${animal.zooSection}'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Szczegóły: ${animal.name}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: animal.details.entries
                                    .map((e) => Text('${e.key}: ${e.value}'))
                                    .toList(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Zamknij'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Pokaż szczegóły'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zamknij')),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('zoo_animals');
            setState(() {
              isLoading = true;
              showList = false;
            });
            loadAnimals();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Wyczyść cache i wczytaj z pliku'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
