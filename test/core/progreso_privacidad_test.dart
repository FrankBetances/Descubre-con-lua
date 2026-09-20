import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/progress_service.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/data/models/fsrs_card_model.dart';

/// El hermano de `test/features/premios_test.dart` para el SEGUNDO fichero que
/// la app guarda en el aparato.
///
/// `premios.json` tenía su gate desde el principio; `user_progress.json` llegó
/// después y no lo tenía, así que nadie paraba una clave nueva —ni una hora—
/// camino del disco. La política de privacidad y el formulario de Play
/// declaran contadores y fechas SIN hora: esto es lo que lo hace cierto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('progreso_privacidad_test');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  ProgressService crear() => ProgressService(
        store: LocalStore(
          fileName: ProgressService.defaultStoreFileName,
          overrideDirectory: dir.path,
        ),
      );

  Future<String> guardadoEnDisco(ProgressService s) async {
    await s.save();
    return File('${dir.path}/${ProgressService.defaultStoreFileName}')
        .readAsStringSync();
  }

  group('lo que user_progress.json guarda, y nada más', () {
    test('solo estas claves: ni un nombre, ni una edad, ni un aparato',
        () async {
      final servicio = crear();
      await servicio.initialize();
      await servicio.recordAssemblyCompleted(
        'asamblea_setembro_01',
        date: DateTime(2026, 3, 10, 9, 30),
      );
      await servicio.recordCapsulaCompleted(
        'capsula_01',
        date: DateTime(2026, 3, 10, 18, 45),
      );
      await servicio.recordFsrsReview(
        FSRSCard.initial(
          id: 1,
          lemma: 'water',
          now: DateTime(2026, 3, 10, 9, 30),
        ),
        3,
        now: DateTime(2026, 3, 10, 9, 30),
      );

      final crudo = await guardadoEnDisco(servicio);

      // Si alguien añade aquí una clave, que sea a conciencia: añadirla obliga
      // a tocar docs/privacy.html y el formulario de Seguridad de los datos de
      // Play Console EN EL MISMO CAMBIO.
      const permitidas = {
        // contadores de la persona adulta
        'xp',
        'currentStreak',
        'bestStreak',
        'lastActiveDate',
        'asambleasCompletadas',
        'capsulasCompletadas',
        'registrosAula',
        'registrosFogar',
        'soundEnabled',
        // el repaso espaciado de la persona adulta: una tarjeta por palabra
        'fsrsCards',
        'id',
        'lemma',
        'difficulty',
        'stability',
        'retrievability',
        'reps',
        'lapses',
        'lastReviewDate',
        'nextDueDate',
        'scheduledDays',
        'state',
      };

      final claves = RegExp(r'"([\w]+)"\s*:')
          .allMatches(crudo)
          .map((m) => m.group(1)!)
          .toSet();
      // Las fechas son claves de mapa («2026-03-10»), no nombres de campo: el
      // guion las deja fuera de \w+ y por eso no entran en la comparación.
      expect(claves.difference(permitidas), isEmpty,
          reason: 'Apareció una clave nueva en $crudo');
    });

    test('ninguna fecha lleva hora, ni en texto ni en milisegundos', () async {
      final servicio = crear();
      await servicio.initialize();
      await servicio.recordAssemblyCompleted(
        'asamblea_setembro_01',
        date: DateTime(2026, 3, 10, 9, 30),
      );
      await servicio.recordFsrsReview(
        FSRSCard.initial(
          id: 7,
          lemma: 'water',
          now: DateTime(2026, 3, 10, 21, 17),
        ),
        4,
        now: DateTime(2026, 3, 10, 21, 17),
      );

      final crudo = await guardadoEnDisco(servicio);

      // Una hora escrita: «21:17», «T21:17:00», cualquier cosa con dos puntos
      // entre dígitos.
      expect(RegExp(r'\d\s*:\s*\d').hasMatch(crudo), isFalse,
          reason: 'Hay una hora en $crudo');
      // Un instante en milisegundos desde 1970: 13 dígitos seguidos. Dice la
      // hora igual de bien que «21:17», solo que sin que se note.
      expect(RegExp(r'\d{13}').hasMatch(crudo), isFalse,
          reason: 'Hay un instante en milisegundos en $crudo');
      // Y las fechas que sí están, están enteras y en formato de día.
      expect(crudo, contains('2026-03-10'));
    });

    test('un registro con hora entra al fichero ya sin hora', () async {
      final servicio = crear();
      await servicio.initialize();
      await servicio.recordRegistroAula('2026-03-10T21:17:00');
      await servicio.recordRegistroFogar('2026-03-11T07:05:00Z');

      final crudo = await guardadoEnDisco(servicio);

      expect(RegExp(r'\d\s*:\s*\d').hasMatch(crudo), isFalse,
          reason: 'La hora sobrevivió en $crudo');
      expect(servicio.registrosAula.keys, contains('2026-03-10'));
      expect(servicio.registrosFogar.keys.first.length, equals(10));
    });

    test('lo guardado vuelve a leerse igual tras cerrar la app', () async {
      final primero = crear();
      await primero.initialize();
      await primero.recordFsrsReview(
        FSRSCard.initial(
          id: 3,
          lemma: 'hello',
          now: DateTime(2026, 3, 10, 9, 30),
        ),
        3,
        now: DateTime(2026, 3, 10, 9, 30),
      );

      final segundo = crear();
      await segundo.initialize();

      final tarjeta = segundo.fsrsCards[3];
      expect(tarjeta, isNotNull);
      expect(tarjeta!.lemma, equals('hello'));
      expect(tarjeta.lastReviewDate.year, equals(2026));
      expect(tarjeta.lastReviewDate.month, equals(3));
      expect(tarjeta.lastReviewDate.day, equals(10));
      // Al volver del disco la fecha es el día a secas: medianoche.
      expect(tarjeta.lastReviewDate.hour, equals(0));
      expect(tarjeta.lastReviewDate.minute, equals(0));
    });
  });
}
