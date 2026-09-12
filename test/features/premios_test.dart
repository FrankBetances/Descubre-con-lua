import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late DateTime reloj;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('premios_test');
    reloj = DateTime(2026, 3, 10, 9, 30);
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  PremiosRepository crear() => PremiosRepository(
        store: LocalStore(
          fileName: 'premios.json',
          overrideDirectory: dir.path,
        ),
        ahora: () => reloj,
      );

  Future<PremiosRepository> cargado() async {
    final repo = crear();
    await repo.cargar();
    return repo;
  }

  group('El XP sale de los contadores, no se guarda aparte', () {
    test('una asamblea y una cápsula suman lo que dice el catálogo', () async {
      final repo = await cargado();
      final c = repo.catalogo!;

      await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      expect(repo.progresoDe(Perfil.docente).xp(c), c.xpPorAsamblea);

      await repo.registrar(Perfil.familia, EventoPremio.capsula);
      expect(repo.progresoDe(Perfil.familia).xp(c), c.xpPorCapsula);
    });

    test('el nivel y lo que falta para el siguiente son coherentes', () async {
      final repo = await cargado();
      final c = repo.catalogo!;

      for (var i = 0; i < 5; i++) {
        reloj = reloj.add(const Duration(days: 1));
        await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      }
      final p = repo.progresoDe(Perfil.docente);

      expect(p.xp(c), 5 * c.xpPorAsamblea);
      expect(p.nivelActual(c).xpMinimo, lessThanOrEqualTo(p.xp(c)));
      final siguiente = p.siguienteNivel(c);
      if (siguiente != null) {
        expect(p.xpParaSiguiente(c), siguiente.xpMinimo - p.xp(c));
        expect(p.avanceDeNivel(c), inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('La racha cuenta días, no sesiones', () {
    test('dos asambleas la misma mañana son un solo día', () async {
      final repo = await cargado();

      await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      await repo.registrar(Perfil.docente, EventoPremio.asamblea);

      final p = repo.progresoDe(Perfil.docente);
      expect(p.asambleas, 2, reason: 'Las dos asambleas cuentan.');
      expect(p.rachaActual, 1,
          reason: 'Pero la racha es de UN día. Si no, abrir y cerrar seis '
              'veces fingiría constancia.');
    });

    test('días consecutivos suman', () async {
      final repo = await cargado();
      for (var i = 0; i < 4; i++) {
        await repo.registrar(Perfil.docente, EventoPremio.asamblea);
        reloj = reloj.add(const Duration(days: 1));
      }
      expect(repo.progresoDe(Perfil.docente).rachaActual, 4);
    });

    test('un día en blanco la rompe, y la mejor racha se recuerda', () async {
      final repo = await cargado();
      for (var i = 0; i < 5; i++) {
        await repo.registrar(Perfil.docente, EventoPremio.asamblea);
        reloj = reloj.add(const Duration(days: 1));
      }
      expect(repo.progresoDe(Perfil.docente).rachaActual, 5);

      reloj = reloj.add(const Duration(days: 3)); // tres días sin abrir
      await repo.registrar(Perfil.docente, EventoPremio.asamblea);

      final p = repo.progresoDe(Perfil.docente);
      expect(p.rachaActual, 1, reason: 'La racha vuelve a empezar.');
      expect(p.mejorRacha, 5, reason: 'La mejor no se pierde.');
    });

    test('una racha vieja se cae al abrir, no se queda congelada', () async {
      final repo = await cargado();
      for (var i = 0; i < 6; i++) {
        await repo.registrar(Perfil.docente, EventoPremio.asamblea);
        reloj = reloj.add(const Duration(days: 1));
      }
      expect(repo.progresoDe(Perfil.docente).rachaActual, 6);

      // Pasa un mes sin tocar la app.
      reloj = reloj.add(const Duration(days: 30));
      await repo.refrescarRachas();

      expect(repo.progresoDe(Perfil.docente).rachaActual, 0,
          reason: 'Una racha que no se cae no es una racha: es un número '
              'viejo que sigue en pantalla.');
      expect(repo.progresoDe(Perfil.docente).mejorRacha, 6);
    });

    test('ayer no rompe la racha: sigue viva hasta que se pierde un día',
        () async {
      final repo = await cargado();
      await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      reloj = reloj.add(const Duration(days: 1));
      await repo.refrescarRachas();
      expect(repo.progresoDe(Perfil.docente).rachaActual, 1);
    });
  });

  group('Las insignias se ganan una vez', () {
    test('registrar devuelve solo las NUEVAS', () async {
      final repo = await cargado();

      final primera =
          await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      expect(primera.map((i) => i.id), contains('primeira_asemblea'));

      reloj = reloj.add(const Duration(days: 1));
      final segunda =
          await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      expect(segunda.map((i) => i.id), isNot(contains('primeira_asemblea')),
          reason: 'Una insignia ya ganada no se vuelve a celebrar.');
    });

    test('la de racha de tres llega justo al tercer día', () async {
      final repo = await cargado();
      var ganadas = <String>[];
      for (var i = 0; i < 3; i++) {
        final nuevas =
            await repo.registrar(Perfil.familia, EventoPremio.capsula);
        ganadas = nuevas.map((n) => n.id).toList();
        if (i < 2) reloj = reloj.add(const Duration(days: 1));
      }
      expect(ganadas, contains('racha_tres'));
    });

    test('cada perfil solo puede ganar las suyas', () async {
      final repo = await cargado();
      final c = repo.catalogo!;

      final deDocente = c.insigniasDe(Perfil.docente).map((i) => i.id).toSet();
      final deFamilia = c.insigniasDe(Perfil.familia).map((i) => i.id).toSet();

      expect(deDocente, isNot(contains('primeira_capsula')));
      expect(deFamilia, isNot(contains('primeira_asemblea')));
      // Las de racha son de los dos.
      expect(deDocente, contains('racha_tres'));
      expect(deFamilia, contains('racha_tres'));
    });
  });

  group('Los dos perfiles no se mezclan', () {
    test('lo que hace la maestra no le cuenta a la familia', () async {
      final repo = await cargado();
      await repo.registrar(Perfil.docente, EventoPremio.asamblea);

      expect(repo.progresoDe(Perfil.docente).asambleas, 1);
      expect(repo.progresoDe(Perfil.familia).asambleas, 0);
      expect(repo.progresoDe(Perfil.familia).rachaActual, 0);
    });
  });

  group('El progreso sobrevive al cierre', () {
    test('se guarda y se vuelve a leer', () async {
      final uno = await cargado();
      await uno.registrar(Perfil.docente, EventoPremio.asamblea);
      reloj = reloj.add(const Duration(days: 1));
      await uno.registrar(Perfil.docente, EventoPremio.asamblea);

      // Otra instancia, como si la app se hubiera cerrado y abierto.
      final dos = await cargado();
      final p = dos.progresoDe(Perfil.docente);
      expect(p.asambleas, 2);
      expect(p.rachaActual, 2);
      expect(p.insignias, contains('primeira_asemblea'));
    });

    test('lo guardado son contadores y fechas, nunca datos de nadie', () async {
      final repo = await cargado();
      await repo.registrar(Perfil.docente, EventoPremio.asamblea);

      final crudo = File('${dir.path}/premios.json').readAsStringSync();
      // Solo estas claves. Si alguien añade un nombre, una edad o un
      // identificador de aparato, este test lo para: eso obligaría a cambiar
      // la política de privacidad y el formulario de Play Console.
      const permitidas = {
        'docente',
        'familia',
        'asambleas',
        'capsulas',
        'rachaActual',
        'mejorRacha',
        'ultimoDia',
        'insignias',
      };
      final claves = RegExp(r'"(\w+)"\s*:')
          .allMatches(crudo)
          .map((m) => m.group(1)!)
          .toSet();
      expect(claves.difference(permitidas), isEmpty,
          reason: 'Apareció una clave nueva en el fichero guardado.');

      // La fecha va sin hora: la hora diría a qué hora trabaja una persona.
      expect(crudo, isNot(contains(':30')));
    });

    test('borrarTodo deja los dos perfiles a cero', () async {
      final repo = await cargado();
      await repo.registrar(Perfil.docente, EventoPremio.asamblea);
      await repo.registrar(Perfil.familia, EventoPremio.capsula);

      await repo.borrarTodo();

      expect(repo.progresoDe(Perfil.docente).eventos, 0);
      expect(repo.progresoDe(Perfil.familia).eventos, 0);
      expect(File('${dir.path}/premios.json').existsSync(), isFalse);
    });
  });

  group('Sin almacenamiento la app no se cae', () {
    test('un directorio imposible no rompe nada', () async {
      final repo = PremiosRepository(
        store: LocalStore(
          fileName: 'premios.json',
          overrideDirectory: '/proc/no-se-puede-escribir-aqui',
        ),
        ahora: () => reloj,
      );
      await repo.cargar();
      final nuevas =
          await repo.registrar(Perfil.docente, EventoPremio.asamblea);

      // Cuenta en memoria aunque no pueda guardar: perder la racha es molesto,
      // que la asamblea se caiga es inaceptable.
      expect(repo.progresoDe(Perfil.docente).asambleas, 1);
      expect(nuevas, isNotEmpty);
    });
  });
}
