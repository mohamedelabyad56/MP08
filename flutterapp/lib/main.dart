import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

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
    print('✅ Firebase inicializado correctamente');
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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final snapshot = await _firestore.collection('ventas').get();

      setState(() {
        _documentos = snapshot.docs;
        _cargando = false;
        _error = snapshot.docs.isEmpty ? 'No hay productos registrados' : '';
      });

      print('📄 Documentos cargados: ${_documentos.length}');

    } catch (e) {
      setState(() {
        _error = 'Error cargando datos: $e';
        _cargando = false;
      });
      print('❌ Error en la consulta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          )
        ],
      ),
      body: _buildContenido(),
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
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
