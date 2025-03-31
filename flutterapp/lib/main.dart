import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Para el debounce

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCV6uor3QEaatKexgDaoKnYU6mibXm-V2g",
        authDomain: "app-flutter-39723.firebaseapp.com",
        projectId: "app-flutter-39723",
        storageBucket: "app-flutter-39723.firebasestorage.app",
        messagingSenderId: "47574810185",
        appId: "1:47574810185:web:7b17a3e0b23c78ff9ac998",
      ),
    );

    await FirebaseAuth.instance.signInAnonymously();
    print('Usuario autenticado anónimamente: ${FirebaseAuth.instance.currentUser?.uid}');
  } catch (e) {
    print('❌ Error de inicialización: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productos Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProductosScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _documentos = [];
  bool _cargando = true;
  String _error = '';

  // Filtros
  RangeValues _cantidadRange = const RangeValues(1, 10); // Rango de cantidades
  RangeValues _precioRange = const RangeValues(0, 100); // Rango de precios
  String _busquedaProducto = ''; // Búsqueda por nombre de producto
  Timer? _debounce; // Para el debounce

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        print('Usuario autenticado anónimamente: ${FirebaseAuth.instance.currentUser?.uid}');
      }

      Query<Map<String, dynamic>> query = _firestore.collection('ventas');

      // Filtro por nombre de producto (insensible a mayúsculas/minúsculas)
      if (_busquedaProducto.isNotEmpty) {
        String searchLower = _busquedaProducto.toLowerCase();
        // Firestore no soporta búsquedas de texto completas directamente.
        // Usamos un rango de búsqueda para aproximar (por ejemplo, "man" buscará "manzana").
        String startAt = searchLower;
        String endAt = searchLower + '\uf8ff'; // \uf8ff es un carácter Unicode alto
        query = query
            .where('producto', isGreaterThanOrEqualTo: startAt)
            .where('producto', isLessThanOrEqualTo: endAt);
      }

      // Filtro por cantidad
      query = query
          .where('cantidad', isGreaterThanOrEqualTo: _cantidadRange.start.round())
          .where('cantidad', isLessThanOrEqualTo: _cantidadRange.end.round());

      // Filtro por precio
      query = query
          .where('precio', isGreaterThanOrEqualTo: _precioRange.start)
          .where('precio', isLessThanOrEqualTo: _precioRange.end);

      final snapshot = await query.get();

      setState(() {
        _documentos = snapshot.docs;
        _cargando = false;
        _error = snapshot.docs.isEmpty ? 'No se encontraron productos con los filtros seleccionados' : '';
      });
    } catch (e) {
      print('Error completo: $e');
      setState(() {
        _error = 'Error cargando datos: $e';
        _cargando = false;
      });
    }
  }

  // Método para manejar el debounce
  void _onFiltroCambiado() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _cargando = true;
      });
      _cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _cantidadRange = const RangeValues(1, 10);
                _precioRange = const RangeValues(0, 100);
                _busquedaProducto = '';
                _cargando = true;
              });
              _cargarDatos();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Búsqueda por nombre
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre de producto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _busquedaProducto = value;
                    });
                    _onFiltroCambiado();
                  },
                ),
                const SizedBox(height: 16),

                // Filtro por cantidad
                const Text('Rango de cantidades', style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: _cantidadRange,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  labels: RangeLabels(
                    _cantidadRange.start.round().toString(),
                    _cantidadRange.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _cantidadRange = values;
                    });
                    _onFiltroCambiado();
                  },
                ),

                // Filtro por precio
                const Text('Rango de precios', style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: _precioRange,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  labels: RangeLabels(
                    _precioRange.start.toStringAsFixed(1),
                    _precioRange.end.toStringAsFixed(1),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _precioRange = values;
                    });
                    _onFiltroCambiado();
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _buildContenido()),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _documentos.length,
      itemBuilder: (context, index) {
        final doc = _documentos[index];
        final data = doc.data() as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.shopping_basket, color: Colors.blue),
            title: Text(
              data['producto']?.toString() ?? 'Producto sin nombre',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoRow('Cantidad:', data['cantidad']?.toString() ?? '0'),
                _buildInfoRow('Precio:', '\$${data['precio']?.toStringAsFixed(2) ?? '0.00'}'),
                _buildInfoRow('Total:', '\$${data['total']?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$titulo ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(valor),
        ],
      ),
    );
  }
}