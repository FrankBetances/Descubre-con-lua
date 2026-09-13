import 'package:flutter/material.dart';
import '../../core/localization/localized_string.dart';

/// Estado de estimulación para un día en el calendario compartido.
enum EstadoEstimulacion {
  sinRegistro,
  soloAula,
  soloHogar,
  dobleEstimulacion,
}

/// Representa una unidad mensual del calendario escolar (Septiembre a Junio)
/// adaptada a la realidad climática, sociocultural y curricular de Galicia (Decreto 150/2022).
class MesCurricular {
  final int orden; // 1 (Septiembre) a 10 (Junio)
  final int mesCalendario; // 9 para septiembre, 10 octubre... 6 junio
  final LocalizedString nombreMes;
  final LocalizedString centroInteres;
  final LocalizedString objetivoPedagogico;
  final List<String> lexicoIngles;
  final List<String> comandosTpr;
  final LocalizedString actividadAula;
  final LocalizedString actividadHogar;
  final LocalizedString rutinaRecomendadaHogar;
  final int minutosAtencionSugeridos;
  final IconData icono;

  const MesCurricular({
    required this.orden,
    required this.mesCalendario,
    required this.nombreMes,
    required this.centroInteres,
    required this.objetivoPedagogico,
    required this.lexicoIngles,
    required this.comandosTpr,
    required this.actividadAula,
    required this.actividadHogar,
    required this.rutinaRecomendadaHogar,
    required this.minutosAtencionSugeridos,
    required this.icono,
  });

  /// Los 10 meses curriculares canónicos del primer ciclo de educación infantil en Galicia.
  static const List<MesCurricular> meses = [
    MesCurricular(
      orden: 1,
      mesCalendario: 9,
      nombreMes: LocalizedString(gl: 'Setembro', es: 'Septiembre'),
      centroInteres: LocalizedString(
        gl: 'Benvida, caricias suaves e novos amigos',
        es: 'Bienvenida, caricias suaves y nuevos amigos',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Vínculo afectivo, adaptación escolar e primeiras fórmulas de saúdo en inglés con palmas asistidas.',
        es: 'Vínculo afectivo, adaptación escolar y primeras fórmulas de saludo en inglés con palmas asistidas.',
      ),
      lexicoIngles: ['Hello', 'Bye-bye', 'Up', 'Down', 'Clap', 'Gentle'],
      comandosTpr: ['Stand up', 'Sit down', 'Clap hands'],
      actividadAula: LocalizedString(
        gl: 'Asemblea en círculo con cinta elástica. Subir mans con "Up" e baixar con "Down".',
        es: 'Asamblea en círculo con cinta elástica. Subir manos con "Up" y bajar con "Down".',
      ),
      actividadHogar: LocalizedString(
        gl: 'Rutina do calzado: elevar os pés con "One shoe, two shoes, Up! Push, push!".',
        es: 'Rutina del calzado: elevar los pies con "One shoe, two shoes, Up! Push, push!".',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Cambio de roupa ou calzado da mañá',
        es: 'Cambio de ropa o calzado de la mañana',
      ),
      minutosAtencionSugeridos: 3,
      icono: Icons.sentiment_satisfied_alt_rounded,
    ),
    MesCurricular(
      orden: 2,
      mesCalendario: 10,
      nombreMes: LocalizedString(gl: 'Outubro', es: 'Octubre'),
      centroInteres: LocalizedString(
        gl: 'O meu pequeno corpo en movemento',
        es: 'Mi pequeño cuerpo en movimiento',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Esquema corporal, propiocepción e dinámica de inhibición motriz ("Freeze!").',
        es: 'Esquema corporal, propiocepción y dinámica de inhibición motriz ("Freeze!").',
      ),
      lexicoIngles: ['Head', 'Tummy', 'Toes', 'Eyes', 'Nose', 'Freeze'],
      comandosTpr: ['Touch your head', 'Shake hands', 'Freeze!'],
      actividadAula: LocalizedString(
        gl: 'Head, Shoulders, Knees and Toes. Parada inmediata ao escoitar "FREEZE!".',
        es: 'Head, Shoulders, Knees and Toes. Parada inmediata al escuchar "FREEZE!".',
      ),
      actividadHogar: LocalizedString(
        gl: 'No baño: masaxe suave na barriga ("Soft tummy") e cosquillas nos pés ("Tickle toes").',
        es: 'En el baño: masaje suave en la barriga ("Soft tummy") y cosquillas en los pies ("Tickle toes").',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Hora do baño ou masaxe antes de durmir',
        es: 'Hora del baño o masaje antes de dormir',
      ),
      minutosAtencionSugeridos: 4,
      icono: Icons.accessibility_new_rounded,
    ),
    MesCurricular(
      orden: 3,
      mesCalendario: 11,
      nombreMes: LocalizedString(gl: 'Novembro', es: 'Noviembre'),
      centroInteres: LocalizedString(
        gl: 'As follas de outono e o Magosto',
        es: 'Las hojas de otoño y el Magosto',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Percepción sensorial da natureza atlántica (follas secas de carballo e castiñeiro).',
        es: 'Percepción sensorial de la naturaleza atlántica (hojas secas de roble y castaño).',
      ),
      lexicoIngles: ['Leaf', 'Falling', 'Wind', 'Crunch', 'Brown', 'Orange'],
      comandosTpr: ['Fall down', 'Walk softly', 'Crunch leaves'],
      actividadAula: LocalizedString(
        gl: 'Chuvia de follas de carballo: caer suave con "Falling down" e pisar forte en "Crunch!".',
        es: 'Lluvia de hojas de roble: caer suave con "Falling down" y pisar fuerte en "Crunch!".',
      ),
      actividadHogar: LocalizedString(
        gl: 'No paseo polo parque: recoller follas secas e facelas estalar ("Crunch, crunch!").',
        es: 'En el paseo por el parque: recoger hojas secas y hacerlas crujir ("Crunch, crunch!").',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Paseo polo parque ou de camiño á escola',
        es: 'Paseo por el parque o de camino a la escuela',
      ),
      minutosAtencionSugeridos: 4,
      icono: Icons.eco_rounded,
    ),
    MesCurricular(
      orden: 4,
      mesCalendario: 12,
      nombreMes: LocalizedString(gl: 'Decembro', es: 'Diciembre'),
      centroInteres: LocalizedString(
        gl: 'Abrazos cálidos, campaíñas e o aire de inverno',
        es: 'Abrazos cálidos, campanitas y el aire de invierno',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Contraste acústico e térmico (rápido/lento, forte/suave, frío/quente).',
        es: 'Contraste acústico y térmico (rápido/lento, fuerte/suave, frío/cálido).',
      ),
      lexicoIngles: ['Cold', 'Warm', 'Bell', 'Ring', 'Sleep', 'Wake up'],
      comandosTpr: ['Ring bells', 'Sleep tight', 'Wake up!'],
      actividadAula: LocalizedString(
        gl: 'Pulseiras de cascabeis: tremer rápido con "Ring fast!" e deitarse en silencio con "Sleep".',
        es: 'Pulseras de cascabeles: temblar rápido con "Ring fast!" y tumbarse en silencio con "Sleep".',
      ),
      actividadHogar: LocalizedString(
        gl: 'Ao arroupar na cama: manta suave dicindo "Warm, soft blanket... Sleep, sleep, wake up!".',
        es: 'Al arropar en la cama: manta suave diciendo "Warm, soft blanket... Sleep, sleep, wake up!".',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Ao deitarse na cama coa mantita',
        es: 'Al acostarse en la cama con la mantita',
      ),
      minutosAtencionSugeridos: 3,
      icono: Icons.notifications_active_rounded,
    ),
    MesCurricular(
      orden: 5,
      mesCalendario: 1,
      nombreMes: LocalizedString(gl: 'Xaneiro', es: 'Enero'),
      centroInteres: LocalizedString(
        gl: 'A roupa de abrigo, botas de chuvia e luvas',
        es: 'La ropa de abrigo, botas de lluvia y manoplas',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Rutinas de autonomía e protección fronte á chuvia e o frío invernal de Galicia.',
        es: 'Rutinas de autonomía y protección frente a la lluvia y el frío invernal de Galicia.',
      ),
      lexicoIngles: ['Coat', 'Boots', 'Hat', 'Put on', 'Take off', 'Big'],
      comandosTpr: ['Put on hat', 'Zip coat', 'Stomp boots'],
      actividadAula: LocalizedString(
        gl: 'Mímica de poñer o abrigo con cremallera imaxinaria ("Zzzip!") e pisar charcos con botas.',
        es: 'Mímica de ponerse el abrigo con cremallera imaginaria ("Zzzip!") y pisar charcos con botas.',
      ),
      actividadHogar: LocalizedString(
        gl: 'Antes de saír á rúa: "Put on your hat! Now boots: stomp, stomp in the floor!".',
        es: 'Antes de salir a la calle: "Put on your hat! Now boots: stomp, stomp in the floor!".',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Preparación para saír da casa',
        es: 'Preparación para salir de casa',
      ),
      minutosAtencionSugeridos: 4,
      icono: Icons.cloudy_snowing,
    ),
    MesCurricular(
      orden: 6,
      mesCalendario: 2,
      nombreMes: LocalizedString(gl: 'Febreiro', es: 'Febrero'),
      centroInteres: LocalizedString(
        gl: 'O reino animal e as festas do Entroido',
        es: 'El reino animal y las fiestas del Entroido',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Locomoción zoomorfa, xogo simbólico e onomatopeas do Entroido.',
        es: 'Locomoción zoomorfa, juego simbólico y onomatopeyas del Entroido.',
      ),
      lexicoIngles: ['Frog', 'Bird', 'Bear', 'Cat', 'Jump', 'Fly'],
      comandosTpr: ['Jump like a frog', 'Fly like a bird', 'Stomp like a bear'],
      actividadAula: LocalizedString(
        gl: 'Circuíto zoomorfo: saltar como ras ("Ribbit!"), voar de puntillas e pisar pesado como un oso.',
        es: 'Circuito zoomorfo: saltar como ranas ("Ribbit!"), volar de puntillas y pisar pesado como un oso.',
      ),
      actividadHogar: LocalizedString(
        gl: 'Xogo de alfombra: gatear como un gato suave ("Sleepy cat... meow") e saltar como unha ra.',
        es: 'Juego de alfombra: gatear como un gato suave ("Sleepy cat... meow") y saltar como una rana.',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Xogo libre sobre a alfombra do salón',
        es: 'Juego libre sobre la alfombra del salón',
      ),
      minutosAtencionSugeridos: 5,
      icono: Icons.pets_rounded,
    ),
    MesCurricular(
      orden: 7,
      mesCalendario: 3,
      nombreMes: LocalizedString(gl: 'Marzo', es: 'Marzo'),
      centroInteres: LocalizedString(
        gl: 'Cores, formas e alimentos sans',
        es: 'Colores, formas y alimentos sanos',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Discriminación visual, cores primarias e hábitos de alimentación sensorial.',
        es: 'Discriminación visual, colores primarios y hábitos de alimentación sensorial.',
      ),
      lexicoIngles: ['Red', 'Yellow', 'Circle', 'Sweet', 'Roll', 'Shake'],
      comandosTpr: ['Find red', 'Roll circle', 'Shake bottle'],
      actividadAula: LocalizedString(
        gl: 'Aros de cores no chan: buscar círculos amarelos e tocalos coa punta do pé ("Touch yellow!").',
        es: 'Aros de colores en el suelo: buscar círculos amarillos y tocarlos con la punta del pie ("Touch yellow!").',
      ),
      actividadHogar: LocalizedString(
        gl: 'Na merenda con froita: mostrar un anaco de mazá vermella ("Red apple, sweet, yummy!").',
        es: 'En la merienda con fruta: mostrar un trozo de manzana roja ("Red apple, sweet, yummy!").',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Hora da merenda ou preparación de comida',
        es: 'Hora de la merienda o preparación de comida',
      ),
      minutosAtencionSugeridos: 4,
      icono: Icons.palette_rounded,
    ),
    MesCurricular(
      orden: 8,
      mesCalendario: 4,
      nombreMes: LocalizedString(gl: 'Abril', es: 'Abril'),
      centroInteres: LocalizedString(
        gl: 'O espertar da primavera, flores e o orballo',
        es: 'El despertar de la primavera, flores y el orballo',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Sensibilización cutánea co orballo galego e xogo corporal de crecemento vexetal.',
        es: 'Sensibilización cutánea con el orballo gallego y juego corporal de crecimiento vegetal.',
      ),
      lexicoIngles: ['Rain', 'Sun', 'Flower', 'Grow', 'Tap-tap', 'Open'],
      comandosTpr: ['Be a seed', 'Grow up', 'Open flower'],
      actividadAula: LocalizedString(
        gl: 'Deitarse como sementes no chan e medrar a modo ata erguer os brazos como flores ("Bloom!").',
        es: 'Tumbarse como semillas en el suelo y crecer despacio hasta abrir los brazos como flores ("Bloom!").',
      ),
      actividadHogar: LocalizedString(
        gl: 'Ante a fiestra un día de choiva suave: tocar o cristal con "Rain, rain, tap, tap, little drops".',
        es: 'Ante la ventana un día de lluvia suave: tocar el cristal con "Rain, rain, tap, tap, little drops".',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Xunto á fiestra ou lavado de mans',
        es: 'Junto a la ventana o lavado de manos',
      ),
      minutosAtencionSugeridos: 4,
      icono: Icons.local_florist_rounded,
    ),
    MesCurricular(
      orden: 9,
      mesCalendario: 5,
      nombreMes: LocalizedString(gl: 'Maio', es: 'Mayo'),
      centroInteres: LocalizedString(
        gl: 'Xogos de auga, chapuzóns e hixiene',
        es: 'Juegos de agua, chapuzones e higiene',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Consolidación de hábitos de hixiene e goce sensoriomotriz coa auga.',
        es: 'Consolidación de hábitos de higiene y disfrute sensoriomotriz con el agua.',
      ),
      lexicoIngles: ['Wash', 'Water', 'Soap', 'Clean', 'Splash', 'Rub'],
      comandosTpr: ['Wash face', 'Rub hands', 'Splash water!'],
      actividadAula: LocalizedString(
        gl: 'Mímica con toalliñas suaves: fregar fazulas ("Wash face") e sacudir as toallas en "Splash!".',
        es: 'Mímica con toallitas suaves: frotar mejillas ("Wash face") y sacudir las toallas en "Splash!".',
      ),
      actividadHogar: LocalizedString(
        gl: 'No lavabo: abrir a billa e sentir a auga temperada ("Warm water! Rub soap, splash, splash!").',
        es: 'En el lavabo: abrir el grifo y sentir el agua templada ("Warm water! Rub soap, splash, splash!").',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Lavado de mans antes de comer ou no baño',
        es: 'Lavado de manos antes de comer o en el baño',
      ),
      minutosAtencionSugeridos: 4,
      icono: Icons.water_drop_rounded,
    ),
    MesCurricular(
      orden: 10,
      mesCalendario: 6,
      nombreMes: LocalizedString(gl: 'Xuño', es: 'Junio'),
      centroInteres: LocalizedString(
        gl: 'Días de sol, o mar e as Rías de Vigo',
        es: 'Días de sol, el mar y las Rías de Vigo',
      ),
      objetivoPedagogico: LocalizedString(
        gl: 'Movemento vestibular colectivo, simulación das ondas mariñas e despedida alegre.',
        es: 'Movimiento vestibular colectivo, simulación de las olas marinas y despedida alegre.',
      ),
      lexicoIngles: ['Sea', 'Waves', 'Swim', 'Fish', 'Blue', 'Goodbye'],
      comandosTpr: ['Gentle waves', 'Big waves!', 'Swim like a fish'],
      actividadAula: LocalizedString(
        gl: 'Paracaídas azul facendo ondas suaves ("Gentle waves") e peixiños nadando por debaixo.',
        es: 'Paracaídas azul haciendo olas suaves ("Gentle waves") y pececitos nadando por debajo.',
      ),
      actividadHogar: LocalizedString(
        gl: 'Cunha saba limpa entre dous adultos ou na cama: ondear e cantar "Blue sea, waves go up and down!".',
        es: 'Con una sábana limpia entre dos adultos o en la cama: ondear y cantar "Blue sea, waves go up and down!".',
      ),
      rutinaRecomendadaHogar: LocalizedString(
        gl: 'Xogo de saba ou manta na cama',
        es: 'Juego de sábana o manta en la cama',
      ),
      minutosAtencionSugeridos: 5,
      icono: Icons.waves_rounded,
    ),
  ];

  /// Devuelve el mes curricular correspondiente a una fecha del año escolar.
  static MesCurricular mesActualParaFecha(DateTime fecha) {
    final mes = fecha.month;
    if (mes == 7 || mes == 8) {
      return meses.first;
    }
    return meses.firstWhere(
      (m) => m.mesCalendario == mes,
      orElse: () => meses.first,
    );
  }
}
