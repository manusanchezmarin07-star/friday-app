// Test básico del shell de F.R.I.D.A.Y.
// Verifica que la estructura de la app se construye sin errores.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:friday_app/main.dart';

void main() {
  testWidgets('F.R.I.D.A.Y. renderiza el TabBar y las 4 pantallas', (WidgetTester tester) async {
    // Inicializamos el socket global (sin conectar realmente en el test)
    socket = IO.io('http://127.0.0.1:9', IO.OptionBuilder().build());

    await tester.pumpWidget(const MaterialApp(home: FridayCore()));

    // El tab bar existe con las 4 secciones
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Núcleo'), findsOneWidget);
    expect(find.text('Comms'), findsOneWidget);
    expect(find.text('Biometría'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);

    // Limpiamos el socket para que no queden timers de reconexión pendientes
    socket.disconnect();
    socket.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}