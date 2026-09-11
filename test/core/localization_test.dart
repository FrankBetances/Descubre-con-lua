import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';

void main() {
  group('AppLanguage tests', () {
    test('Language codes and display names are correct', () {
      expect(AppLanguage.gl.code, equals('gl'));
      expect(AppLanguage.gl.displayName, equals('Galego'));
      expect(AppLanguage.gl.flagLabel, equals('GL'));

      expect(AppLanguage.es.code, equals('es'));
      expect(AppLanguage.es.displayName, equals('Castellano'));
      expect(AppLanguage.es.flagLabel, equals('ES'));
    });

    test('fromCode resolves properly with fallback to gl', () {
      expect(AppLanguage.fromCode('es'), equals(AppLanguage.es));
      expect(AppLanguage.fromCode('es-ES'), equals(AppLanguage.es));
      expect(AppLanguage.fromCode('gl'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('gl-ES'), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode(null), equals(AppLanguage.gl));
      expect(AppLanguage.fromCode('unknown'), equals(AppLanguage.gl));
    });

    test('toggle alternates between gl and es', () {
      expect(AppLanguage.gl.toggle(), equals(AppLanguage.es));
      expect(AppLanguage.es.toggle(), equals(AppLanguage.gl));
    });
  });

  group('LocalizedString tests', () {
    const text = LocalizedString(
      gl: 'O mar de Vigo',
      es: 'El mar de Vigo',
    );

    test('resolve returns correct variant for each language', () {
      expect(text.resolve(AppLanguage.gl), equals('O mar de Vigo'));
      expect(text.resolve(AppLanguage.es), equals('El mar de Vigo'));
    });

    test('hasParity returns true when both variants are non-blank', () {
      expect(text.hasParity, isTrue);

      const missingEs = LocalizedString(gl: 'Ola', es: '');
      expect(missingEs.hasParity, isFalse);

      const blankGl = LocalizedString(gl: '   ', es: 'Hola');
      expect(blankGl.hasParity, isFalse);
    });

    test('fromJson and toJson round-trip preserves content', () {
      final json = {'gl': 'Bateas na ría', 'es': 'Bateas en la ría'};
      final parsed = LocalizedString.fromJson(json);

      expect(parsed.gl, equals('Bateas na ría'));
      expect(parsed.es, equals('Bateas en la ría'));
      expect(parsed.toJson(), equals(json));
    });

    test('equality and copyWith work as expected', () {
      const copy = LocalizedString(gl: 'O mar de Vigo', es: 'El mar de Vigo');
      expect(text, equals(copy));
      expect(text.hashCode, equals(copy.hashCode));

      final updated = text.copyWith(es: 'Nuevo texto');
      expect(updated.gl, equals('O mar de Vigo'));
      expect(updated.es, equals('Nuevo texto'));
    });
  });
}
