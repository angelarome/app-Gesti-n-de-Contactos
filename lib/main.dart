import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Contactos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaFormulario(),
      routes: {
        '/lista': (context) => const PantallaLista(),
      },
    );
  }
}

class PantallaFormulario extends StatefulWidget {
  const PantallaFormulario({super.key});

  @override
  State<PantallaFormulario> createState() => _PantallaFormularioState();
}

class _PantallaFormularioState extends State<PantallaFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  Future<void> _guardarContacto(String nombre, String telefono) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contactos = prefs.getStringList('contactos') ?? [];
    contactos.add('$nombre: $telefono');
    await prefs.setStringList('contactos', contactos);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto guardado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Contacto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa un número' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _guardarContacto(
                        _nombreController.text, _telefonoController.text);
                    _nombreController.clear();
                    _telefonoController.clear();
                  }
                },
                child: const Text('Guardar Contacto'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/lista'),
                child: const Text('Ver Lista de Contactos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}

class PantallaLista extends StatefulWidget {
  const PantallaLista({super.key});

  @override
  State<PantallaLista> createState() => _PantallaListaState();
}

class _PantallaListaState extends State<PantallaLista> {
  List<String> _contactos = [];
  List<String> _contactosFiltrados = [];
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarContactos();
    _busquedaController.addListener(_filtrarContactos);
  }

  Future<void> _cargarContactos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contactos = prefs.getStringList('contactos') ?? [];
    setState(() {
      _contactos = contactos;
      _contactosFiltrados = contactos;
    });
  }

  void _filtrarContactos() {
    final query = _busquedaController.text.toLowerCase();
    setState(() {
      _contactosFiltrados =
          _contactos.where((c) => c.toLowerCase().contains(query)).toList();
    });
  }

  void _descargarContactos() {
    final contenido = _contactos.join('\n');
    final bytes = utf8.encode(contenido);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "contactos.txt")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> _eliminarContacto(String contacto) async {
    final prefs = await SharedPreferences.getInstance();
    _contactos.remove(contacto);
    _contactosFiltrados.remove(contacto);
    await prefs.setStringList('contactos', _contactos);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Contactos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _busquedaController,
              decoration: const InputDecoration(
                labelText: 'Buscar contacto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _contactosFiltrados.isEmpty
                ? const Center(child: Text('No hay contactos'))
                : ListView.builder(
                    itemCount: _contactosFiltrados.length,
                    itemBuilder: (context, index) {
                      final contacto = _contactosFiltrados[index];
                      return ListTile(
                        title: Text(contacto),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _eliminarContacto(contacto),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Descargar Contactos'),
              onPressed: _descargarContactos,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
