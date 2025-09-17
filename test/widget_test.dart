import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ejercicio2/main.dart'; // ajusta si tu package name es distinto

void main() {
  // Asegura bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Mock inicial de SharedPreferences - importante para que no falle en test
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Formulario carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MiAplicacion());
    await tester.pumpAndSettle();

    // AppBar
    expect(find.text('Formulario'), findsOneWidget);

    // Debe haber 2 TextFormField (nombre y teléfono)
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Botones
    expect(find.widgetWithText(ElevatedButton, 'Guardar Contacto'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ver Lista de Contactos'), findsOneWidget);
  });

  testWidgets('Navegación a la lista de contactos', (WidgetTester tester) async {
    await tester.pumpWidget(const MiAplicacion());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Ver Lista de Contactos'));
    await tester.pumpAndSettle();

    expect(find.text('Lista de Contactos'), findsOneWidget);
    expect(find.text('No hay contactos guardados'), findsOneWidget);
  });

  testWidgets('Guardar contacto y mostrar en la lista', (WidgetTester tester) async {
    await tester.pumpWidget(const MiAplicacion());
    await tester.pumpAndSettle();

    // Rellena los dos campos: usamos .first y .last sobre find.byType(TextFormField)
    await tester.enterText(find.byType(TextFormField).first, 'Juan');
    await tester.enterText(find.byType(TextFormField).last, '123-456-7890');

    // Toca Guardar
    await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar Contacto'));

    // Espera a que terminen las operaciones async y el snackbar
    await tester.pumpAndSettle();

    // Navega a la lista
    await tester.tap(find.widgetWithText(ElevatedButton, 'Ver Lista de Contactos'));
    await tester.pumpAndSettle();

    // Verifica que el contacto guardado esté en la lista
    expect(find.text('Juan: 123-456-7890'), findsOneWidget);
  });
}
