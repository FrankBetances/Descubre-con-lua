import '../../core/localization/app_language.dart';

/// El nombre de una categoría de láminas, como se lee en pantalla.
///
/// Lo usan los chips de la galería y la cabecera de cada lámina: así la misma
/// categoría se llama igual en los dos sitios.
String nomeCategoria(String clave, AppLanguage lang) {
  const nombres = <String, List<String>>{
    'todas': ['Todas', 'Todas'],
    'alfabeto': ['Alfabeto', 'Alfabeto'],
    'vocabulario': ['Vocabulario', 'Vocabulario'],
    'animais': ['Animais', 'Animales'],
    'vigo_natureza': ['Vigo e natureza', 'Vigo y naturaleza'],
    'escola_rutinas': ['Escola e rutinas', 'Escuela y rutinas'],
    'emocions_corpo': ['Emocións e corpo', 'Emociones y cuerpo'],
    'cuento_ilustrado': ['Contos ilustrados', 'Cuentos ilustrados'],
  };
  final par = nombres[clave];
  if (par == null) return clave.replaceAll('_', ' ');
  return lang == AppLanguage.gl ? par[0] : par[1];
}
