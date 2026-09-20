import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

late IO.Socket socket;

// Dirección del backend. Por defecto localhost (PC/escritorio).
// Para el móvil se cambia al compilar:
//   flutter build ipa --dart-define=FRIDAY_HOST=192.168.1.50
const String _hostBackend = String.fromEnvironment('FRIDAY_HOST', defaultValue: '127.0.0.1');

void main() {
  socket = IO.io('http://$_hostBackend:3000', IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    home: FridayCore(),
  ));
}

// ==========================================
// METADATA DE LOS AGENTES J.A.R.V.I.S.
// ==========================================
class AgenteInfo {
  final String id;
  final String nombre;
  final String corto;
  final IconData icono;
  final Color color;
  final String descripcion;

  const AgenteInfo({
    required this.id,
    required this.nombre,
    required this.corto,
    required this.icono,
    required this.color,
    required this.descripcion,
  });
}

const List<AgenteInfo> agentesJarvis = [
  AgenteInfo(
    id: 'JARVIS_ACADEMICO',
    nombre: 'J.A.R.V.I.S. Académico',
    corto: 'Académico',
    icono: Icons.school,
    color: Color(0xFF5B8DEF),
    descripcion: 'Estudios DAM: Java, Kotlin, bases de datos, exámenes y organización.',
  ),
  AgenteInfo(
    id: 'JARVIS_DEPORTISTA',
    nombre: 'J.A.R.V.I.S. Deportista',
    corto: 'Deportista',
    icono: Icons.fitness_center,
    color: Color(0xFF43D17C),
    descripcion: 'Rendimiento físico: rutinas, cargas y progresión en el gimnasio.',
  ),
  AgenteInfo(
    id: 'JARVIS_SEGURIDAD',
    nombre: 'J.A.R.V.I.S. Seguridad',
    corto: 'Seguridad',
    icono: Icons.security,
    color: Color(0xFFFF4D5A),
    descripcion: 'El Cazador de Hackers: vigila las entradas y protege tu red.',
  ),
  AgenteInfo(
    id: 'JARVIS_SOFTWARE',
    nombre: 'J.A.R.V.I.S. Software',
    corto: 'Software',
    icono: Icons.code,
    color: Color(0xFFB06BFF),
    descripcion: 'Mentor Socrático: te hace pensar y descubrir el error solo.',
  ),
  AgenteInfo(
    id: 'JARVIS_MUSICO',
    nombre: 'J.A.R.V.I.S. Músico',
    corto: 'Músico',
    icono: Icons.music_note,
    color: Color(0xFFFF5FA2),
    descripcion: 'Producción musical con Cubase 13, teoría y recomendaciones.',
  ),
  AgenteInfo(
    id: 'JARVIS_MECANICO',
    nombre: 'J.A.R.V.I.S. Mecánico',
    corto: 'Mecánico',
    icono: Icons.settings,
    color: Color(0xFFFFA726),
    descripcion: 'Diagnóstico del sistema: CPU, RAM y salud general del PC.',
  ),
  AgenteInfo(
    id: 'JARVIS_SOCIAL',
    nombre: 'J.A.R.V.I.S. Social',
    corto: 'Social',
    icono: Icons.group,
    color: Color(0xFF26C6DA),
    descripcion: 'Mantiene vivo el contacto con tu gente importante.',
  ),
  AgenteInfo(
    id: 'JARVIS_GENERAL',
    nombre: 'Núcleo General',
    corto: 'General',
    icono: Icons.psychology,
    color: Color(0xFF00E5FF),
    descripcion: 'Cerebro local: responde a todo lo que no es de ningún otro agente.',
  ),
];

class FridayCore extends StatefulWidget {
  const FridayCore({super.key});
  @override
  State<FridayCore> createState() => _FridayCoreState();
}

class _FridayCoreState extends State<FridayCore> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = [
    const PantallaRed(),
    const PantallaChat(),
    const PantallaSalud(),
    const PantallaSistema(),
  ];

  @override
  void initState() {
    super.initState();
    // Alertas proactivas del J.A.R.V.I.S. Social (llegan cuando toca)
    socket.on('alerta_social', (data) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF162032),
          content: Text(
            data.toString(),
            style: const TextStyle(color: Colors.cyanAccent),
          ),
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
        ));
      });
    });
    // Alertas del vigilante Moodle (cambios en el campus)
    socket.on('alerta_moodle', (data) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF1A1500),
          content: Text(
            data.toString(),
            style: const TextStyle(color: Colors.amberAccent),
          ),
          duration: const Duration(seconds: 12),
          behavior: SnackBarBehavior.floating,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.cyanAccent.withOpacity(0.3), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) => setState(() => _indiceActual = index),
          backgroundColor: const Color(0xFF0A0E17),
          selectedItemColor: Colors.cyanAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.memory), label: 'Núcleo'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Comms'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Biometría'),
            BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Sistema'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. PANTALLA NÚCLEO — RED J.A.R.V.I.S.
// Apartados por agente + flujo compacto arriba
// ==========================================
const List<String> _nodosTuberia = ['Recepción', 'Núcleo NLP', 'Enrutador'];

class PantallaRed extends StatefulWidget {
  const PantallaRed({super.key});
  @override
  State<PantallaRed> createState() => _PantallaRedState();
}

class _PantallaRedState extends State<PantallaRed> {
  List<String> nodosActivos = [];

  @override
  void initState() {
    super.initState();
    socket.on('estado_flujo', (data) {
      if (mounted) {
        setState(() {
          nodosActivos = List<String>.from(data['nodos_activos']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.memory, color: Colors.cyanAccent, size: 18),
                SizedBox(width: 8),
                Text("F.R.I.D.A.Y. — RED J.A.R.V.I.S.",
                    style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            // Flujo compacto en vivo
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _nodosTuberia.length; i++) ...[
                    _chipFlujo(_nodosTuberia[i], Icons.psychology,
                        activo: nodosActivos.contains(_nodosTuberia[i])),
                    if (i < _nodosTuberia.length - 1)
                      Icon(Icons.arrow_forward, size: 16, color: Colors.grey.withOpacity(0.5)),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey.withOpacity(0.5)),
                  ),
                  ...agentesJarvis
                      .where((a) => nodosActivos.contains(a.nombre))
                      .map((a) => _chipFlujo(a.nombre, a.icono, activo: true, color: a.color)),
                  if (nodosActivos.isEmpty) _chipFlujo('-', Icons.more_horiz, activo: false),
                ],
              ),
            ),
            const Divider(color: Colors.grey, height: 20),
            // Malla compacta: los 8 agentes visibles sin scrollear
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: agentesJarvis
                        .map((a) => _tarjetaAgente(context, a))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipFlujo(String texto, IconData icono, {required bool activo, Color? color}) {
    final c = color ?? (activo ? Colors.cyanAccent : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: activo ? c.withOpacity(0.15) : const Color(0xFF162032),
        border: Border.all(color: c.withOpacity(activo ? 0.9 : 0.3), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icono, color: c, size: 14),
          const SizedBox(width: 5),
          Text(texto,
              style: TextStyle(
                  color: activo ? Colors.white : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _tarjetaAgente(BuildContext context, AgenteInfo agente) {
    final activo = nodosActivos.contains(agente.nombre);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PantallaApartado(agente: agente)),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 78,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111927),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activo ? agente.color : agente.color.withOpacity(0.3),
            width: activo ? 2 : 1,
          ),
          boxShadow: activo
              ? [BoxShadow(color: agente.color.withOpacity(0.3), blurRadius: 10)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: agente.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(agente.icono, color: agente.color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(agente.corto,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1b. PANTALLA APARTADO DE UN AGENTE
// ==========================================
class PantallaApartado extends StatefulWidget {
  final AgenteInfo agente;
  const PantallaApartado({super.key, required this.agente});

  @override
  State<PantallaApartado> createState() => _PantallaApartadoState();
}

class _PantallaApartadoState extends State<PantallaApartado> {
  Map<String, dynamic>? datos;
  bool _cargando = true;

  void _onDatosAgente(dynamic data) {
    if (data is Map && data['agente'] == widget.agente.id) {
      if (mounted) {
        setState(() {
          datos = Map<String, dynamic>.from(data);
          _cargando = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    socket.on('datos_agente', _onDatosAgente);
    socket.emit('peticion_datos', widget.agente.id);
  }

  @override
  void dispose() {
    socket.off('datos_agente', _onDatosAgente);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.agente;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(a.icono, color: a.color, size: 20),
            const SizedBox(width: 8),
            Text(a.nombre, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _cargando
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : ListView(
                  children: [
                    _tarjetaDescripcion(a),
                    const SizedBox(height: 16),
                    if (datos != null) _renderDatos(datos!),
                    const SizedBox(height: 16),
                    _avisoChat(a),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _tarjetaDescripcion(AgenteInfo a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: a.color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: a.color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(a.icono, color: a.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(a.descripcion,
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _avisoChat(AgenteInfo a) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: a.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: a.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.forum, color: a.color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Toda la conversación conmigo va en el Chat de Comms. Este es mi panel de estado.',
              style: TextStyle(color: a.color.withOpacity(0.9), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Render por tipo de datos ──
  Widget _renderDatos(Map<String, dynamic> d) {
    final a = widget.agente;
    switch (d['tipo']) {
      case 'lista':
        final items = List<Map<String, dynamic>>.from(d['items'] ?? []);
        if (items.isEmpty) return _cajaVacia(d['vacio']?.toString() ?? 'Sin datos.', a.color);
        return Column(
          children: items
              .map((it) => _itemLista(it, a.color,
                  destacado: it['destacado'] == true))
              .toList(),
        );

      case 'stats':
        return _renderStats(d, a.color);

      case 'contador':
        return _renderContador(d, a.color);

      case 'sistema':
        return _renderSistema(d, a.color);

      case 'texto':
      default:
        return _cajaVacia(d['mensaje']?.toString() ?? '', a.color);
    }
  }

  Widget _cajaVacia(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _itemLista(Map<String, dynamic> it, Color color, {required bool destacado}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: destacado ? color : color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(it['titulo']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              if (it['fecha'] != null)
                Text(it['fecha'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          if (it['subtitulo'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(it['subtitulo'].toString(),
                  style: TextStyle(color: destacado ? color : Colors.grey, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _renderStats(Map<String, dynamic> d, Color color) {
    final criticos = (d['criticos'] ?? 0).toInt();
    final medios = (d['medios'] ?? 0).toInt();
    final bajos = (d['bajos'] ?? 0).toInt();
    final total = (d['total'] ?? 0).toInt();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111927),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text('$total', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const Text('Amenazas registradas', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _chipStat('CRÍTICAS', criticos, const Color(0xFFFF4D5A)),
            const SizedBox(width: 8),
            _chipStat('MEDIAS', medios, const Color(0xFFFFA726)),
            const SizedBox(width: 8),
            _chipStat('BAJAS', bajos, const Color(0xFF26C6DA)),
          ],
        ),
        const SizedBox(height: 8),
        Text('La barrera del Cazador de Hackers sigue operativa.',
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _chipStat(String etiqueta, int valor, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111927),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Text('$valor', style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(etiqueta, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _renderContador(Map<String, dynamic> d, Color color) {
    final valor = (d['valor'] ?? 0).toInt();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111927),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text('$valor',
                  style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.bold)),
              Text(d['unidad']?.toString() ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: valor / 5.0,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF0A0E17),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _cajaVacia(d['mensaje']?.toString() ?? '', color),
      ],
    );
  }

  Widget _renderSistema(Map<String, dynamic> d, Color color) {
    final cpu = (d['cpu'] ?? 0).toDouble();
    final ram = (d['ram'] ?? 0).toDouble();

    return _cajaSistema(
      d,
      cpu,
      ram,
      color,
    );
  }

  Widget _cajaSistema(Map<String, dynamic> d, double cpu, double ram, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CPU', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${cpu.round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (cpu / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFF0A0E17),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RAM', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${ram.round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (ram / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFF0A0E17),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          _filaTile(Icons.memory, 'Libre', '${d['ramLibre'] ?? 0} GB de ${d['ramTotal'] ?? 0} GB'),
          _filaTile(Icons.timer, 'Uptime', '${d['uptime'] ?? 0} horas'),
          _filaTile(Icons.computer, 'F.R.I.D.A.Y.', '${d['proceso'] ?? 0} MB'),
        ],
      ),
    );
  }

  Widget _filaTile(IconData icono, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icono, color: Colors.grey, size: 15),
          const SizedBox(width: 8),
          Expanded(child: Text(k, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. PANTALLA CHAT — ÚNICA PUERTA DE CONVERSACIÓN
// ==========================================
class PantallaChat extends StatefulWidget {
  const PantallaChat({super.key});
  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final TextEditingController _controladorTexto = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> mensajes = [];
  String? _agenteSeleccionado; // null = auto-routing

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _grabador = AudioRecorder();
  bool _estaGrabando = false;

  @override
  void initState() {
    super.initState();
    socket.on('respuesta_friday', (data) {
      if(mounted) {
        setState(() => mensajes.add({"emisor": "friday", "tipo": "texto", "contenido": data}));
        _hacerScrollHaciaAbajo();
      }
    });
  }

  void enviarOrden() {
    if (_controladorTexto.text.isNotEmpty) {
      socket.emit('mensaje_usuario', _controladorTexto.text);
      setState(() => mensajes.add({"emisor": "usuario", "tipo": "texto", "contenido": _controladorTexto.text}));
      _controladorTexto.clear();
      _hacerScrollHaciaAbajo();
    }
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      setState(() {
        mensajes.add({"emisor": "usuario", "tipo": "imagen", "contenido": imagen.path});
      });
      _hacerScrollHaciaAbajo();

      final bytes = await File(imagen.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      socket.emit('mensaje_imagen', {'imagen': base64Image});
    }
  }

  Future<void> _controlarGrabacion() async {
    if (await _grabador.hasPermission()) {
      if (_estaGrabando) {
        final rutaAudio = await _grabador.stop();
        setState(() => _estaGrabando = false);

        if (rutaAudio != null) {
          setState(() => mensajes.add({"emisor": "usuario", "tipo": "texto", "contenido": "🎤 [Nota de voz enviada]"}));
          _hacerScrollHaciaAbajo();

          final bytes = await File(rutaAudio).readAsBytes();
          socket.emit('mensaje_audio', {'audio': base64Encode(bytes)});
        }
      } else {
        final directorio = await getApplicationDocumentsDirectory();
        await _grabador.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: '${directorio.path}/orden.m4a');
        setState(() => _estaGrabando = true);
      }
    }
  }

  void _hacerScrollHaciaAbajo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _seleccionarAgente(String? agenteId) {
    setState(() => _agenteSeleccionado = agenteId);
    socket.emit('seleccionar_agente', agenteId ?? '');
  }

  Widget _buildSelectorAgentes() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          _chipAgente(null, Icons.auto_awesome, 'Auto', Colors.cyanAccent),
          ...agentesJarvis.map((a) => _chipAgente(a.id, a.icono, a.corto, a.color)),
        ],
      ),
    );
  }

  Widget _chipAgente(String? agenteId, IconData icono, String label, Color color) {
    final seleccionado = _agenteSeleccionado == agenteId;
    return GestureDetector(
      onTap: () => _seleccionarAgente(agenteId),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.2) : const Color(0xFF162032),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: seleccionado ? color : color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: seleccionado ? color : Colors.grey, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: seleccionado ? Colors.white : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorTexto.dispose();
    _scrollController.dispose();
    _grabador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSelectorAgentes(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                final esUsuario = msg["emisor"] == "usuario";

                return Align(
                  alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: esUsuario ? Colors.cyan.withOpacity(0.1) : const Color(0xFF162032),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: esUsuario ? Colors.cyanAccent.withOpacity(0.5) : Colors.transparent),
                    ),
                    child: msg["tipo"] == "texto"
                        ? Text(msg["contenido"], style: const TextStyle(color: Colors.white, fontSize: 15))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(msg["contenido"]), height: 150, fit: BoxFit.cover),
                          ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_estaGrabando ? Icons.stop_circle : Icons.mic,
                             color: _estaGrabando ? Colors.redAccent : Colors.grey),
                  onPressed: _controlarGrabacion,
                ),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.grey),
                  onPressed: _seleccionarImagen,
                ),
                Expanded(
                  child: TextField(
                    controller: _controladorTexto,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Habla con F.R.I.D.A.Y...',
                      filled: true,
                      fillColor: const Color(0xFF162032),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => enviarOrden(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.cyanAccent), onPressed: enviarOrden)
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 3. PANTALLA BIOMETRÍA (pendiente de hardware)
// ==========================================
class PantallaSalud extends StatefulWidget {
  const PantallaSalud({super.key});
  @override
  State<PantallaSalud> createState() => _PantallaSaludState();
}

class _PantallaSaludState extends State<PantallaSalud> {
  List<dynamic> mediciones = [];
  Map<String, dynamic>? _rutina;

  @override
  void initState() {
    super.initState();
    socket.on('datos_biometricos', (data) {
      if (mounted) {
        setState(() {
          mediciones = List<dynamic>.from(data);
        });
      }
    });
    socket.on('datos_rutina', (data) {
      if (mounted && data is Map) {
        setState(() => _rutina = Map<String, dynamic>.from(data));
      }
    });
    socket.emit('peticion_rutina');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ── Biometrics section ──
            Row(
              children: [
                const Icon(Icons.monitor_weight_outlined, color: Colors.lightGreenAccent, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Biometría — últimas mediciones',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Alimentado por capturas enviadas al chat (okok International y similares).',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(color: Colors.grey, height: 24),
            if (mediciones.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Aún sin mediciones. Envía una captura de okok por el chat.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...mediciones.map((m) {
                final fecha = m['date']?.toString() ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162032),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Medición ${m['id']}',
                              style: const TextStyle(
                                  color: Colors.lightGreenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(fecha, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (m['weight'] != null) _dato('Peso', '${m['weight']} kg'),
                          if (m['body_fat'] != null) _dato('Grasa', '${m['body_fat']}%'),
                          if (m['bmi'] != null) _dato('IMC', '${m['bmi']}'),
                          if (m['muscle_mass'] != null) _dato('Músculo', '${m['muscle_mass']} kg'),
                          if (m['water_percentage'] != null) _dato('Agua', '${m['water_percentage']}%'),
                        ],
                      ),
                      if (m['source'] != null) ...[
                        const SizedBox(height: 8),
                        Text('Fuente: ${m['source']}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // ── Routine section ──
            _buildSeccionRutina(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionRutina() {
    final rutina = _rutina;
    final ejercicios = rutina != null ? List<dynamic>.from(rutina['ejercicios'] as List? ?? []) : <dynamic>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.greenAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rutina != null ? 'Rutina — ${rutina['dia'] ?? 'Hoy'}' : 'Rutina de hoy',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.grey, size: 18),
              onPressed: () => socket.emit('peticion_rutina'),
              tooltip: 'Actualizar rutina',
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text('Toca un ejercicio para registrar la carga completada.',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const Divider(color: Colors.grey, height: 20),
        if (ejercicios.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No hay rutina definida para hoy.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...ejercicios.map((e) => _tarjetaEjercicio(Map<String, dynamic>.from(e as Map))),
      ],
    );
  }

  Widget _tarjetaEjercicio(Map<String, dynamic> e) {
    final completado = (e['completado'] as int? ?? 0) == 1;
    return GestureDetector(
      onTap: () => _mostrarDialogoCompletar(e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: completado ? const Color(0xFF0D2010) : const Color(0xFF162032),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: completado
                ? Colors.greenAccent.withOpacity(0.5)
                : Colors.greenAccent.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              completado ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completado ? Colors.greenAccent : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e['ejercicio']?.toString() ?? '',
                      style: TextStyle(
                          color: completado ? Colors.greenAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  if ((e['maquina']?.toString() ?? '').isNotEmpty)
                    Text(e['maquina'].toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${e['series'] ?? 3} × ${e['reps'] ?? 10}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('${e['carga_kg'] ?? 0} kg',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCompletar(Map<String, dynamic> ejercicio) {
    final ctrlKg =
        TextEditingController(text: ejercicio['carga_kg']?.toString() ?? '0');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111927),
        title: Text(ejercicio['ejercicio']?.toString() ?? 'Ejercicio',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${ejercicio['series'] ?? 3} series × ${ejercicio['reps'] ?? 10} reps',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrlKg,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Carga completada (kg)',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF162032),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                suffixText: 'kg',
                suffixStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.withOpacity(0.2)),
            onPressed: () {
              final kg =
                  double.tryParse(ctrlKg.text.replaceAll(',', '.')) ?? 0.0;
              socket.emit('completar_ejercicio', {'id': ejercicio['id'], 'kg': kg});
              Navigator.pop(ctx);
            },
            child: const Text('Completar',
                style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1626),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightGreenAccent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

// ==========================================
// 4. PANTALLA SISTEMA (Monitor en vivo)
// ==========================================
class PantallaSistema extends StatefulWidget {
  const PantallaSistema({super.key});
  @override
  State<PantallaSistema> createState() => _PantallaSistemaState();
}

class _PantallaSistemaState extends State<PantallaSistema> {
  Map<String, dynamic>? datos;

  @override
  void initState() {
    super.initState();
    socket.on('datos_sistema', (data) {
      if (mounted) {
        setState(() {
          datos = Map<String, dynamic>.from(data);
        });
      }
    });
  }

  Widget _barra(String etiqueta, double porcentaje, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text("${porcentaje.round()}%", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (porcentaje / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFF162032),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = datos;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: d == null
            ? const Center(child: Text("Sistema\n[ Conectando con el núcleo... ]", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center))
            : ListView(
                children: [
                  Row(
                    children: [
                      Icon(Icons.computer, color: Colors.cyanAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(d['hostname']?.toString() ?? 'F.R.I.D.A.Y.', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(d['platform']?.toString() ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(color: Colors.grey, height: 24),

                  _barra(
                    'CPU (${d['cpuUsoPorcentaje'] ?? 0}%)',
                    (d['cpuUsoPorcentaje'] ?? 0).toDouble(),
                    Colors.cyanAccent,
                  ),
                  Text(d['cpuModelo']?.toString() ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${d['cpuNucleos'] ?? 0} núcleos', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),

                  _barra(
                    'RAM (${d['ramUsoPorcentaje'] ?? 0}%)',
                    (d['ramUsoPorcentaje'] ?? 0).toDouble(),
                    (d['ramUsoPorcentaje'] ?? 0) > 85 ? Colors.redAccent : Colors.cyanAccent,
                  ),
                  Text('${d['ramLibreGB'] ?? 0} GB libres de ${d['ramTotalGB'] ?? 0} GB', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),

                  _buildTile(Icons.timer, 'Uptime', '${d['uptimeHoras'] ?? 0} horas'),
                  _buildTile(Icons.memory, 'Memoria F.R.I.D.A.Y.', '${d['memoriaProcesoMB'] ?? 0} MB'),
                ],
              ),
      ),
    );
  }

  Widget _buildTile(IconData icono, String titulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF162032),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icono, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(titulo, style: const TextStyle(color: Colors.grey))),
          Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}