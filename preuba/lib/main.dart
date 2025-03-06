import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Animaciones en Flutter'), // Títol de la barra d'aplicacions
        ),
        body: const Center(
          child: AnimacionesDemo(), // Widget central que conté la demostració de les animacions
        ),
      ),
    );
  }
}

class AnimacionesDemo extends StatefulWidget {
  /*
    aquesta línia de codi defineix un constructor constant per a la classe AnimacionesDemo,
     que accepta un paràmetre opcional key i passa aquest paràmetre al constructor de la seva
     superclasse. Això és comú en els widgets personalitzats de Flutter
     i permet l'ús de claus en la creació d'instàncies d'aquests widgets.
     Les claus en Flutter s'utilitzen per controlar la identitat dels widgets
     i ajudar en el procés de reconstrucció i actualització de l'arbre de widgets.
  */
  const AnimacionesDemo({Key? key}) : super(key: key);
  const AssetImage('assets/logow.png')
  @override
  _AnimacionesDemoState createState() => _AnimacionesDemoState();
}

/*
Un TickerProvider és una interfície utilitzada per crear instàncies d'objectes Ticker.
 Alguns widgets, com AnimationController, requereixen un TickerProvider
 per funcionar correctament.

TickerProviderStateMixin és un mixin que implementa la interfície TickerProvider
i proporciona una implementació bàsica per crear instàncies d'objectes Ticker.
Aquesta classe mixin s'utilitza comunament en els State objectes dels StatefulWidget
que requereixen animacions.
 */
class _AnimacionesDemoState extends State<AnimacionesDemo> with TickerProviderStateMixin {
  /*
  late és una paraula clau en Dart que s'utilitza per indicar que una variable
  d'instància no s'inicialitzarà en la seva declaració, sinó que s'assignarà
  més tard abans que s'utilitzi. És útil quan no pots
  proporcionar un valor inicial per a una variable durant la seva declaració
  o en el constructor, però encara vols garantir que la variable s'inicialitzarà
  abans del seu primer ús.
  */
  late final AnimationController _scaleController; // Controlador per a l'animació d'escala
  late final AnimationController _rotationController; // Controlador per a l'animació de rotació
  late final AnimationController _opacityController; // Controlador per a l'animació d'opacitat
  late final AnimationController _slideController; // Controlador per a l'animació de lliscament

  late final Animation<double> _scaleAnimation; // Animació d'escala (valors double)
  late final Animation<double> _rotationAnimation; // Animació de rotació (valors double)
  late final Animation<double> _opacityAnimation; // Animació d'opacitat (valors double)
  late final Animation<Offset> _slideAnimation; // Animació de lliscament (valors Offset per a la posició)

  /* recordeu que les variables final no poden canviar de valor una vegada
  que se'ls ha declarat
   */

  @override
  void initState() {
    /*
    super.initState(); és una crida al mètode initState() de la classe base
    (superclase) en Flutter. Aquesta línia de codi s'utilitza típicament en el
     mètode initState() d'un objecte State quan s'extendeix un StatefulWidget.

   Quan es crea un StatefulWidget en Flutter,
   el framework crea un objecte State corresponent.
   El mètode initState() es crida automàticament una vegada quan es crea
   aquest objecte State, abans que es construeixi el widget.
   Aquest mètode és el lloc ideal per realitzar inicialitzacions
   específiques de l'estat, com carregar dades, iniciar animacions
    o subscriure's a esdeveniments.

    Tanmateix, quan se sobreescriu el mètode initState() en una subclasse de State,
    és crucial cridar al mètode initState() de la superclasse utilitzant super.initState();
   per garantir que l'objecte State s'inicialitzi correctament
   segons les implementacions de la superclasse. La crida a super.initState();
   ha de ser la primera línia en el mètode initState() sobreescrit.
     */
    super.initState();

    _scaleController = AnimationController( // Inicialitza el controlador d'animació d'escala
      duration: const Duration(seconds: 2), // Durada de l'animació: 2 segons
      vsync: this, // Sincronització amb el ticker del widget per a un rendiment òptim
    );
    _rotationController = AnimationController( // Inicialitza el controlador d'animació de rotació
      duration: const Duration(seconds: 2), // Durada de l'animació: 2 segons
      vsync: this, // Sincronització amb el ticker del widget
    );
    _opacityController = AnimationController( // Inicialitza el controlador d'animació d'opacitat
      duration: const Duration(seconds: 2), // Durada de l'animació: 2 segons
      vsync: this, // Sincronització amb el ticker del widget
    );
    _slideController = AnimationController( // Inicialitza el controlador d'animació de lliscament
      duration: const Duration(seconds: 1), // Durada de l'animació: 1 segon
      vsync: this, // Sincronització amb el ticker del widget
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 2).animate(_scaleController); // Defineix l'animació d'escala: de 1x a 2x la mida original
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.1415926535).animate(_rotationController); // Defineix l'animació de rotació: de 0 a 360 graus (2*PI radiants)
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(_opacityController); // Defineix l'animació d'opacitat: de completament opac (1) a completament transparent (0)
    _slideAnimation = Tween<Offset>(begin: const Offset(-2, 0), end: const Offset(2, 0)).animate(_slideController); // Defineix l'animació de lliscament: de fora de la pantalla a l'esquerra a fora de la pantalla a la dreta

    _scaleController.repeat(reverse: true); // Inicia i repeteix l'animació d'escala indefinidament, invertint-la al final de cada cicle
    _rotationController.repeat(reverse: true); // Inicia i repeteix l'animació de rotació indefinidament, invertint-la al final de cada cicle
    _opacityController.repeat(reverse: true); // Inicia i repeteix l'animació d'opacitat indefinidament, invertint-la al final de cada cicle
    _slideController.repeat(reverse: true); // Inicia i repeteix l'animació de lliscament indefinidament, invertint-la al final de cada cicle
  }

  @override
  void dispose() {
    _scaleController.dispose(); // Allibera els recursos del controlador d'animació d'escala quan el widget ja no és necessari
    _rotationController.dispose(); // Allibera els recursos del controlador d'animació de rotació quan el widget ja no és necessari
    _opacityController.dispose(); // Allibera els recursos del controlador d'animació d'opacitat quan el widget ja no és necessari
    _slideController.dispose(); // Allibera els recursos del controlador d'animació de lliscament quan el widget ja no és necessari
    super.dispose(); // Crida al mètode dispose() de la superclasse per a tasques de neteja addicionals
  }

  @override
  Widget build(BuildContext context) {
    return Column( // Disposa els widgets fills verticalment
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribueix l'espai vertical uniformement
      children: [
        ScaleTransition( // Aplica l'animació d'escala
          scale: _scaleAnimation, // Anima la propietat d'escala amb _scaleAnimation
          child: const FlutterLogo(size: 50), // Widget fill: Logo de Flutter amb mida 50
        ),
        RotationTransition( // Aplica l'animació de rotació
          turns: _rotationAnimation, // Anima la propietat de rotació amb _rotationAnimation (en voltes)
          child: const FlutterLogo(size: 50), // Widget fill: Logo de Flutter amb mida 50
        ),
        FadeTransition( // Aplica l'animació de fosa (opacitat)
          opacity: _opacityAnimation, // Anima la propietat d'opacitat amb _opacityAnimation
          child: const FlutterLogo(size: 50), // Widget fill: Logo de Flutter amb mida 50
        ),
        SlideTransition( // Aplica l'animació de lliscament (posició)
          position: _slideAnimation, // Anima la propietat de posició amb _slideAnimation
          child: const FlutterLogo(size: 50), // Widget fill: Logo de Flutter amb mida 50
        ),
      ],
    );
  }
}

