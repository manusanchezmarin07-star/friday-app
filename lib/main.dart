import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late IO.Socket socket;

const String _hostDefecto = '100.127.132.67';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final host = prefs.getString('server_host') ?? _hostDefecto;

  socket = IO.io('http://$host:3000', IO.OptionBuilder()
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
    const PantallaConfig(),
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
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
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
        MaterialPageRoute(
          builder: (_) => agente.id == 'JARVIS_DEPORTISTA'
              ? const PantallaGym()
              : PantallaApartado(agente: agente),
        ),
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
              .map((it) => _itemLista(it, a.color, destacado: it['destacado'] == true))
              .toList(),
        );

      case 'academico':
        return _renderAcademico(d, a.color);

      case 'musico':
        return _renderMusico(d, a.color);

      case 'social':
        return _renderSocial(d, a.color);

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

  Widget _renderAcademico(Map<String, dynamic> d, Color color) {
    final tareas = List<Map<String, dynamic>>.from(d['tareas'] ?? []);
    final moodle = List<Map<String, dynamic>>.from(d['moodle'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _seccionHeader(Icons.assignment_outlined, 'TAREAS PENDIENTES', color),
        const SizedBox(height: 8),
        if (tareas.isEmpty)
          _cajaVacia('No hay tareas pendientes. ¡Impecable!', color)
        else
          ...tareas.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111927),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 10),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['asignatura']?.toString() ?? '',
                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(t['descripcion']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (t['fecha'] != null)
                      Text(t['fecha'].toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              )),
        const SizedBox(height: 16),
        _seccionHeader(Icons.school_outlined, 'CAMPUS VIRTUAL (MOODLE)', color),
        const SizedBox(height: 8),
        if (moodle.isEmpty)
          _cajaVacia('Sin cambios detectados en el campus todavía.', color)
        else
          ...moodle.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['emoji']?.toString() ?? '🔔',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['titulo']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                          if ((m['detalle']?.toString() ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(m['detalle'].toString(),
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),
                    if ((m['creado_en']?.toString() ?? '').isNotEmpty)
                      Text(m['creado_en'].toString().substring(0, 10),
                          style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _renderMusico(Map<String, dynamic> d, Color color) {
    final total = (d['total'] ?? 0) as int;
    final canciones = List<Map<String, dynamic>>.from(d['canciones'] ?? []);
    final generos = List<String>.from(d['topGeneros'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111927),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text('$total',
                        style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold)),
                    const Text('canciones analizadas',
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ),
            if (generos.isNotEmpty) ...[
              const SizedBox(width: 10),
              Column(
                children: generos
                    .map((g) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withOpacity(0.35)),
                          ),
                          child: Text(g,
                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _seccionHeader(Icons.queue_music, 'ÚLTIMAS ANALIZADAS', color),
        const SizedBox(height: 8),
        if (canciones.isEmpty)
          _cajaVacia('Todavía no guardé canciones. Decime en el chat: "registra [canción] de [artista]"', color)
        else
          ...canciones.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111927),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.music_note, color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['nombre']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            [c['artista'], c['genero']].where((x) => x != null && x.toString().isNotEmpty).join(' · '),
                            style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (c['fecha'] != null)
                      Text(c['fecha'].toString(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _renderSocial(Map<String, dynamic> d, Color color) {
    final contactos = List<Map<String, dynamic>>.from(d['contactos'] ?? []);
    if (contactos.isEmpty) {
      return _cajaVacia('No hay contactos VIP. En el chat: "registra a mi abuela como VIP cada 3 días"', color);
    }

    final pendientes = contactos.where((c) => c['urgencia'] != 'ok').toList()
      ..sort((a, b) => (b['diasPendiente'] as int).compareTo(a['diasPendiente'] as int));
    final alDia = contactos.where((c) => c['urgencia'] == 'ok').toList();

    Color _colorUrgencia(String? u) {
      if (u == 'alta') return const Color(0xFFFF4D5A);
      if (u == 'media') return const Color(0xFFFFA726);
      return const Color(0xFF43D17C);
    }

    Widget _tarjetaContacto(Map<String, dynamic> c) {
      final urgencia = c['urgencia']?.toString() ?? 'ok';
      final uc = _colorUrgencia(urgencia);
      final diasDesde = c['diasDesde'] as int? ?? 0;
      final diasPend = c['diasPendiente'] as int? ?? 0;
      final freq = c['frecuenciaDias'] as int? ?? 0;

      String subtitulo;
      if (urgencia == 'ok') {
        subtitulo = 'Al día — quedan ${(-diasPend)} días';
      } else {
        subtitulo = diasPend == 0 ? '¡Hoy toca contactar!' : 'Hace $diasPend día${diasPend == 1 ? '' : 's'} que toca';
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111927),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: uc.withOpacity(urgencia == 'ok' ? 0.2 : 0.6), width: urgencia == 'alta' ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: uc, shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c['nombre']?.toString() ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitulo, style: TextStyle(color: uc, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('cada $freq d', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                Text('hace $diasDesde d', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendientes.isNotEmpty) ...[
          _seccionHeader(Icons.notifications_active_outlined, 'PENDIENTES DE CONTACTO', const Color(0xFFFF4D5A)),
          const SizedBox(height: 8),
          ...pendientes.map(_tarjetaContacto),
          const SizedBox(height: 16),
        ],
        _seccionHeader(Icons.check_circle_outline, 'AL DÍA', const Color(0xFF43D17C)),
        const SizedBox(height: 8),
        if (alDia.isEmpty)
          _cajaVacia('Nadie al día por ahora.', color)
        else
          ...alDia.map(_tarjetaContacto),
      ],
    );
  }

  Widget _seccionHeader(IconData icono, String texto, Color color) {
    return Row(
      children: [
        Icon(icono, color: color, size: 14),
        const SizedBox(width: 6),
        Text(texto,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ],
    );
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
  String? _agenteSeleccionado;
  bool _esperandoRespuesta = false;

  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _grabador = AudioRecorder();
  bool _estaGrabando = false;

  @override
  void initState() {
    super.initState();
    socket.on('respuesta_friday', (data) {
      if (mounted) {
        setState(() {
          _esperandoRespuesta = false;
          mensajes.add({"emisor": "friday", "tipo": "texto", "contenido": data});
        });
        _hacerScrollHaciaAbajo();
      }
    });
  }

  void enviarOrden() {
    if (_controladorTexto.text.isNotEmpty) {
      socket.emit('mensaje_usuario', _controladorTexto.text);
      setState(() {
        mensajes.add({"emisor": "usuario", "tipo": "texto", "contenido": _controladorTexto.text});
        _esperandoRespuesta = true;
      });
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
      if (mounted) setState(() => _esperandoRespuesta = true);
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
          if (mounted) setState(() => _esperandoRespuesta = true);
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

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF162032),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                color: Colors.cyanAccent,
                backgroundColor: Color(0xFF0A0E17),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'F.R.I.D.A.Y. procesando...',
              style: TextStyle(
                color: Colors.cyanAccent.withOpacity(0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
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
              itemCount: mensajes.length + (_esperandoRespuesta ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == mensajes.length && _esperandoRespuesta) {
                  return _buildTypingIndicator();
                }
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

// ==========================================
// 5. PANTALLA GYM — J.A.R.V.I.S. DEPORTISTA
// ==========================================
class PantallaGym extends StatefulWidget {
  const PantallaGym({super.key});
  @override
  State<PantallaGym> createState() => _PantallaGymState();
}

class _PantallaGymState extends State<PantallaGym> {
  static const Color _color = Color(0xFF43D17C);
  static const Map<int, String> _etiquetas = {
    1: 'Empuje', 2: 'Pierna', 3: 'Tirón', 4: 'Full Body',
  };

  int _diaSeleccionado = 1;
  String _diaNombre = 'Lunes';
  List<Map<String, dynamic>> _ejercicios = [];
  List<Map<String, dynamic>> _statsSubidas = [];
  bool _sesionIniciada = false;
  bool _cargando = false;

  void _onDatosRutina(dynamic data) {
    if (!mounted || data is! Map) return;
    setState(() {
      _ejercicios = List<Map<String, dynamic>>.from(
        (data['ejercicios'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      _diaNombre = data['dia']?.toString() ?? _diaNombre;
      _cargando = false;
    });
  }

  void _onStatsGym(dynamic data) {
    if (!mounted || data is! List) return;
    setState(() {
      _statsSubidas = List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e as Map)),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    socket.on('datos_rutina', _onDatosRutina);
    socket.on('stats_gym', _onStatsGym);
    socket.emit('obtener_stats_gym');
  }

  @override
  void dispose() {
    socket.off('datos_rutina', _onDatosRutina);
    socket.off('stats_gym', _onStatsGym);
    super.dispose();
  }

  void _iniciarSesion() {
    setState(() {
      _cargando = true;
      _sesionIniciada = true;
    });
    socket.emit('iniciar_sesion_gym', {'numeroDia': _diaSeleccionado});
  }

  void _onEjercicioCompletado(Map<String, dynamic> ejercicio, double kg) {
    socket.emit('completar_ejercicio', {
      'id': ejercicio['id'],
      'kg': kg,
      'dia': _diaNombre,
      'ejercicio': ejercicio['ejercicio'],
    });
    setState(() {
      final idx = _ejercicios.indexWhere((e) => e['id'] == ejercicio['id']);
      if (idx >= 0) {
        _ejercicios[idx] = {..._ejercicios[idx], 'completado': 1, 'carga_kg': kg};
      }
    });
    socket.emit('obtener_stats_gym');
  }

  void _abrirHojaEjercicio(Map<String, dynamic> ejercicio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HojaEjercicio(
        ejercicio: ejercicio,
        onCompletar: (kg) => _onEjercicioCompletado(ejercicio, kg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completados = _ejercicios.where((e) => (e['completado'] as int? ?? 0) == 1).length;
    final total = _ejercicios.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(children: [
          Icon(Icons.fitness_center, color: Color(0xFF43D17C), size: 20),
          SizedBox(width: 8),
          Text('J.A.R.V.I.S. Deportista', style: TextStyle(color: Colors.white, fontSize: 16)),
        ]),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_statsSubidas.isNotEmpty) ...[
              _buildStatsCard(),
              const SizedBox(height: 16),
            ],
            _buildSelectorDia(),
            const SizedBox(height: 16),
            if (!_sesionIniciada)
              _buildBotonIniciar()
            else if (_cargando)
              const Center(child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: CircularProgressIndicator(color: Color(0xFF43D17C)),
              ))
            else ...[
              if (total > 0)
                _buildProgresoSesion(completados, total),
              const SizedBox(height: 10),
              ..._ejercicios.map((e) => _buildTarjetaEjercicio(e)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.trending_up, color: Color(0xFF43D17C), size: 16),
            const SizedBox(width: 8),
            const Text('Esta semana subiste de peso en:',
                style: TextStyle(color: Color(0xFF43D17C), fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
          const SizedBox(height: 10),
          ..._statsSubidas.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [
              const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: Text(s['ejercicio']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              Text('${s['kgAnterior']} → ${s['kgActual']} kg',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildSelectorDia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Qué sesión toca hoy?',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (i) {
            final n = i + 1;
            final sel = _diaSeleccionado == n;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _diaSeleccionado = n;
                  _sesionIniciada = false;
                  _ejercicios = [];
                }),
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? _color.withOpacity(0.2) : const Color(0xFF111927),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? _color : _color.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Día $n',
                          style: TextStyle(
                              color: sel ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      Text(_etiquetas[n]!,
                          style: TextStyle(
                              color: sel ? _color : Colors.grey,
                              fontSize: 10)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBotonIniciar() {
    return GestureDetector(
      onTap: _iniciarSesion,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, color: Color(0xFF43D17C), size: 26),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Empezar sesión — Día $_diaSeleccionado',
                    style: const TextStyle(
                        color: Color(0xFF43D17C),
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(_etiquetas[_diaSeleccionado]!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgresoSesion(int completados, int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111927),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progreso sesión — $_diaNombre',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('$completados / $total',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? completados / total : 0,
              minHeight: 6,
              backgroundColor: const Color(0xFF0A0E17),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF43D17C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaEjercicio(Map<String, dynamic> e) {
    final completado = (e['completado'] as int? ?? 0) == 1;
    return GestureDetector(
      onTap: () => _abrirHojaEjercicio(e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: completado ? const Color(0xFF0D2010) : const Color(0xFF111927),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: completado ? _color.withOpacity(0.6) : _color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              completado ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completado ? _color : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e['ejercicio']?.toString() ?? '',
                      style: TextStyle(
                        color: completado ? _color : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )),
                  if ((e['maquina']?.toString() ?? '').isNotEmpty)
                    Text(e['maquina'].toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${e['series'] ?? 3} × ${e['reps'] ?? '10'}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text('${(e['carga_kg'] ?? 0).toStringAsFixed(1)} kg',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5b. HOJA EJERCICIO — slider + series + timer
// ==========================================
class _HojaEjercicio extends StatefulWidget {
  final Map<String, dynamic> ejercicio;
  final void Function(double kg) onCompletar;

  const _HojaEjercicio({required this.ejercicio, required this.onCompletar});

  @override
  State<_HojaEjercicio> createState() => _HojaEjercicioState();
}

class _HojaEjercicioState extends State<_HojaEjercicio> {
  static const Color _color = Color(0xFF43D17C);

  late double _kg;
  late double _kgMin;
  late double _kgMax;
  late int _totalSeries;
  int _seriesCompletadas = 0;

  Timer? _timer;
  int _segundos = 0;
  bool _timerActivo = false;
  bool _timerEsSerie = true;
  bool _ejercicioFinalizado = false;

  @override
  void initState() {
    super.initState();
    final lastKg = (widget.ejercicio['carga_kg'] as num?)?.toDouble() ?? 0.0;
    _totalSeries = (widget.ejercicio['series'] as int?) ?? 3;
    _kg = lastKg > 0 ? lastKg : 20.0;
    _kgMin = lastKg > 20 ? lastKg - 20 : 0.0;
    _kgMax = lastKg > 0 ? lastKg + 30 : 100.0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarTimer(int segundosTotales, bool esSerie) {
    _timer?.cancel();
    setState(() {
      _segundos = segundosTotales;
      _timerActivo = true;
      _timerEsSerie = esSerie;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_segundos > 0) {
          _segundos--;
        } else {
          _timerActivo = false;
          t.cancel();
          if (_ejercicioFinalizado) Navigator.pop(context);
        }
      });
    });
  }

  void _completarSerie(int indice) {
    if (_seriesCompletadas != indice) return;
    setState(() => _seriesCompletadas++);
    if (_seriesCompletadas < _totalSeries) {
      _iniciarTimer(60, true);
    }
  }

  void _completarEjercicio() {
    widget.onCompletar(_kg);
    setState(() => _ejercicioFinalizado = true);
    _iniciarTimer(120, false);
  }

  void _saltarDescanso() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  String _formatoTiempo(int s) {
    final m = s ~/ 60;
    final seg = s % 60;
    return '${m.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.ejercicio['ejercicio']?.toString() ?? 'Ejercicio';
    final maquina = widget.ejercicio['maquina']?.toString() ?? '';
    final reps = widget.ejercicio['reps']?.toString() ?? '10';
    final rango = _kgMax - _kgMin;
    final divisiones = (rango / 2.5).round().clamp(1, 9999);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111927),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Si el ejercicio ya está finalizado, mostramos solo el timer de descanso
            if (_ejercicioFinalizado) ...[
              const Center(
                child: Icon(Icons.check_circle, color: Color(0xFF43D17C), size: 48),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('¡Ejercicio completado!',
                    style: TextStyle(
                        color: _color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              _buildTimer(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.skip_next, color: Colors.grey),
                label: const Text('Saltar descanso',
                    style: TextStyle(color: Colors.grey)),
                onPressed: _saltarDescanso,
              ),
            ] else ...[
              // Nombre + máquina
              Text(nombre,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              if (maquina.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(maquina,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              const SizedBox(height: 16),

              // Info series/reps + timer siempre visible
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0E17),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoCol('Series', '$_totalSeries'),
                          Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                          _infoCol('Reps', reps),
                          Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                          _infoCol('Hechas', '$_seriesCompletadas/$_totalSeries'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildTimerCompacto(),
                ],
              ),
              const SizedBox(height: 20),

              // Slider kg
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Carga',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('${_kg.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _color,
                  inactiveTrackColor: _color.withOpacity(0.2),
                  thumbColor: _color,
                  overlayColor: _color.withOpacity(0.15),
                  valueIndicatorColor: _color,
                  valueIndicatorTextStyle:
                      const TextStyle(color: Colors.black),
                ),
                child: Slider(
                  value: _kg.clamp(_kgMin, _kgMax),
                  min: _kgMin,
                  max: _kgMax,
                  divisions: divisiones,
                  label: '${_kg.toStringAsFixed(1)} kg',
                  onChanged: (v) {
                    final snapped =
                        ((v / 2.5).round() * 2.5).clamp(_kgMin, _kgMax);
                    setState(() => _kg = snapped);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_kgMin.toStringAsFixed(0)} kg',
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  Text('${_kgMax.toStringAsFixed(0)} kg',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 20),

              // Series tracker
              Row(
                children: List.generate(_totalSeries, (i) {
                  final hecho = i < _seriesCompletadas;
                  final siguiente = i == _seriesCompletadas;
                  return Expanded(
                    child: GestureDetector(
                      onTap: siguiente ? () => _completarSerie(i) : null,
                      child: Container(
                        margin: EdgeInsets.only(right: i < _totalSeries - 1 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: hecho
                              ? _color.withOpacity(0.2)
                              : const Color(0xFF0A0E17),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hecho
                                ? _color
                                : siguiente
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          hecho ? Icons.check : Icons.fitness_center,
                          color: hecho
                              ? _color
                              : siguiente
                                  ? Colors.white
                                  : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _seriesCompletadas < _totalSeries
                      ? 'Toca la serie ${_seriesCompletadas + 1} cuando la termines'
                      : 'Todas las series completadas ✓',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Botón completar (solo cuando todas las series están hechas)
              if (_seriesCompletadas >= _totalSeries)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    'Completar ejercicio — ${_kg.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: _completarEjercicio,
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Timer siempre visible al lado del info de series
  Widget _buildTimerCompacto() {
    final activo = _timerActivo;
    final Color color;
    final String tiempo;
    final String etiqueta;

    if (activo) {
      color = _timerEsSerie ? Colors.amberAccent : Colors.lightBlueAccent;
      tiempo = _formatoTiempo(_segundos);
      etiqueta = _timerEsSerie ? 'serie' : 'ejercicio';
    } else {
      color = Colors.grey;
      final proxDecanso = _seriesCompletadas >= _totalSeries ? 120 : 60;
      tiempo = _formatoTiempo(proxDecanso);
      etiqueta = _seriesCompletadas >= _totalSeries ? 'ejercicio' : 'serie';
    }

    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: activo ? color.withOpacity(0.12) : const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: activo ? color.withOpacity(0.6) : Colors.grey.withOpacity(0.2),
          width: activo ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: color, size: activo ? 18 : 14),
          const SizedBox(height: 4),
          Text(
            tiempo,
            style: TextStyle(
              color: activo ? color : Colors.grey,
              fontSize: activo ? 18 : 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            etiqueta,
            style: TextStyle(color: activo ? color.withOpacity(0.8) : Colors.grey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    final esSerie = _timerEsSerie;
    final color = esSerie ? Colors.amberAccent : Colors.lightBlueAccent;
    final label = esSerie ? 'Descanso entre series' : 'Descanso entre ejercicios';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatoTiempo(_segundos),
            style: TextStyle(
              color: color,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCol(String label, String valor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }
}

// ==========================================
// 6. PANTALLA CONFIG — Servidor
// ==========================================
class PantallaConfig extends StatefulWidget {
  const PantallaConfig({super.key});
  @override
  State<PantallaConfig> createState() => _PantallaConfigState();
}

class _PantallaConfigState extends State<PantallaConfig> {
  final _ctrl = TextEditingController();
  String _mensaje = '';
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    _cargarHost();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHost() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('server_host') ?? _hostDefecto;
    setState(() => _ctrl.text = host);
  }

  Future<void> _guardar() async {
    final host = _ctrl.text.trim();
    if (host.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_host', host);
    setState(() {
      _guardado = true;
      _mensaje = 'Guardado. Cierra y vuelve a abrir la app para conectar.';
    });
  }

  void _restaurar() {
    setState(() => _ctrl.text = _hostDefecto);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.settings, color: Colors.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text('Configuración',
                  style: TextStyle(
                      color: Colors.cyanAccent,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111927),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Servidor F.R.I.D.A.Y.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text(
                    'IP o nombre de host de tu PC. Usa la IP de Tailscale para acceder desde cualquier sitio.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      hintText: _hostDefecto,
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF0A0E17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: ':3000',
                      suffixStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Guardar',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _guardar,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _restaurar,
                        child: const Text('Restaurar',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_mensaje.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _guardado
                        ? Colors.greenAccent.withOpacity(0.1)
                        : Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _guardado
                            ? Colors.greenAccent.withOpacity(0.4)
                            : Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _guardado ? Icons.check_circle : Icons.error,
                        color: _guardado ? Colors.greenAccent : Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_mensaje,
                            style: TextStyle(
                                color: _guardado
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111927),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Conexión actual',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _filaCon(Icons.circle,
                      socket.connected ? 'Conectado' : 'Desconectado',
                      socket.connected ? Colors.greenAccent : Colors.redAccent),
                  const SizedBox(height: 4),
                  _filaCon(Icons.dns, socket.io.uri, Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaCon(IconData icono, String texto, Color color) {
    return Row(
      children: [
        Icon(icono, color: color, size: 13),
        const SizedBox(width: 8),
        Expanded(
            child: Text(texto,
                style: TextStyle(color: color, fontSize: 12),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}