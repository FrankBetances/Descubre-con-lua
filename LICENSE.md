# Licencia de «Descubre con Lúa · Edición Vigo»

**Versión 1.0 · 13 de septiembre de 2026**

Titular de los derechos: **Earlify Health S.L.**, y el Dr. Frank Alberto
Betances Reinoso como autor.
Contacto: **frank.alberto.betances.reinoso@gmail.com**

> **Resumen en una línea.** Para una familia o una persona a título individual,
> gratis y para siempre. Para una institución o una empresa, hace falta una
> licencia por escrito. Este resumen no sustituye al texto: manda el articulado
> de abajo.

---

## 1. Qué cubre esta licencia

Cubre **este repositorio y la aplicación que se compila a partir de él**:

- el código fuente;
- el contenido pedagógico (`assets/content/`): unidades, cápsulas, calendario
  curricular, léxico y frases en inglés, catálogo de premios;
- las grabaciones de voz de `assets/voice/`, sintetizadas por el titular;
- la mascota Lúa y las ilustraciones, iconos e insignias propias;
- la documentación (`docs/`, `README.md`, `PROJECT.md`, `STATUS.md`).

**No cubre** los componentes de terceros que la app incorpora, que conservan
cada uno su licencia propia (apartado 8), ni los logotipos institucionales
ajenos (apartado 7).

## 2. Definiciones

- **Uso personal o familiar**: el que hace una persona física, por su cuenta,
  en su propio ámbito doméstico o con las criaturas a su cargo, sin cobrar a
  nadie por ello y sin actuar por cuenta de ninguna entidad.
- **Uso institucional**: cualquier uso realizado por una persona jurídica o una
  administración pública, o por alguien que actúa por cuenta de ellas, **aunque
  sea gratuito y aunque la entidad no tenga ánimo de lucro**. Entran aquí, entre
  otros: escuelas infantiles, colegios, ayuntamientos, consellerías, hospitales,
  centros de salud, gabinetes, asociaciones, fundaciones, ONG, universidades y
  centros de formación.
- **Uso comercial**: el dirigido a obtener un beneficio económico directo o
  indirecto, incluido cobrar por la app, por servicios prestados con ella, por
  formación basada en ella, o incorporarla a un producto o servicio de pago.

Una misma persona puede hacer los dos: una maestra que usa la app en su casa
con su hija hace uso personal; esa misma maestra usándola en su aula hace uso
institucional.

## 3. Uso personal o familiar: gratis

El titular concede a cualquier persona física, **sin coste, de forma no
exclusiva, mundial y por tiempo indefinido**, el derecho a:

1. instalar y usar la aplicación para uso personal o familiar, en los
   dispositivos que quiera;
2. leer, estudiar y compilar el código fuente de este repositorio;
3. modificarlo para su propio uso personal o familiar;
4. hacer copias privadas de seguridad;
5. imprimir para su propia casa los materiales imprimibles que la app ofrezca.

No hay que pedir permiso, ni registrarse, ni avisar. **Esta licencia no caduca
para quien ya la esté usando así.**

## 4. Uso institucional: requiere licencia por escrito

Cualquier uso institucional, según la definición del apartado 2, **requiere una
licencia previa y por escrito del titular**, aunque la entidad no cobre nada a
las familias y aunque el uso sea puntual.

Se pide escribiendo a **frank.alberto.betances.reinoso@gmail.com**. Las
condiciones de cada licencia institucional —alcance, duración, número de aulas o
de centros, soporte, formación y precio— se acuerdan caso por caso, **y pueden
incluir la cesión gratuita** cuando el titular así lo decida, por ejemplo en
convenios con administraciones públicas o en proyectos piloto.

Mientras no exista esa licencia firmada, una institución no está autorizada a
desplegar la aplicación, ni a recomendarla como herramienta propia, ni a
incluirla en su material o en sus programas.

## 5. Uso comercial: requiere licencia por escrito

Igual que el anterior, y por la misma vía. En particular, **no** están
autorizados sin licencia previa:

- vender la aplicación, o cobrar por instalarla o configurarla;
- prestar servicios de pago —terapia, refuerzo, formación, consultoría— usando
  la aplicación o su contenido como herramienta;
- incorporar el código, el contenido, las grabaciones o la mascota a otro
  producto, aplicación o plataforma;
- publicar la aplicación, o una versión derivada de ella, en cualquier tienda
  de aplicaciones.

## 6. Lo que esta licencia no concede en ningún caso

Ni el uso personal ni el familiar autorizan a:

- redistribuir públicamente la aplicación o el repositorio, ni subir a ninguna
  tienda una versión propia o derivada;
- sublicenciar, alquilar o ceder los derechos de esta licencia a un tercero;
- retirar, ocultar o alterar los créditos, la autoría, los avisos de licencia o
  la pantalla de créditos de la aplicación;
- presentar el trabajo como propio, ni usarlo para entrenar modelos de
  aprendizaje automático con fines comerciales;
- usar el nombre «Descubre con Lúa», la mascota Lúa, «Earlify Health» o el
  escudo del autor para identificar productos o servicios de un tercero.

Contribuir al repositorio (una corrección, una traducción, un error) sí está
permitido y se agradece; quien contribuya conserva la autoría de su aportación y
concede al titular el derecho a incorporarla bajo esta misma licencia.

## 7. Marcas y logotipos ajenos

Los logotipos institucionales que aparecen en los créditos —Concello de Vigo,
Consorcio da Zona Franca de Vigo, programa startTIC— **son marcas de sus
titulares y no se licencian aquí**. Su presencia acredita una colaboración; no
implica que quien reciba esta licencia pueda usarlos. Ver
`assets/brand/logos/README.md`.

## 8. Componentes de terceros

La aplicación incorpora trabajo de terceros que **conserva su propia licencia** y
queda fuera del alcance de este documento:

| Componente | Qué es | Dónde están sus términos |
| --- | --- | --- |
| Nunito | Tipografía | SIL Open Font License 1.1, incluida en `assets/fonts/OFL.txt` |
| Flutter, Dart y sus paquetes | Marco de trabajo y dependencias | Licencias de cada proyecto, según `pubspec.lock` |
| Celtia · Proxecto Nós | Modelo de voz en gallego, usado en compilación | Términos del modelo en su repositorio de origen |
| Sharvard · rhasspy/piper-voices | Modelo de voz en castellano, usado en compilación | Términos del modelo en su repositorio de origen |
| LJSpeech · rhasspy/piper-voices | Modelo de voz en inglés, usado en compilación | Términos del modelo en su repositorio de origen |

Los modelos de voz **no viajan en la aplicación y no se ejecutan en el
dispositivo**: solo se usan en tiempo de compilación para producir los ficheros
de audio que sí viajan. Quien vaya a hacer uso institucional o comercial debe
comprobar por su cuenta que los términos de cada modelo amparan ese uso.

## 9. Sin garantía

La aplicación se entrega **«tal cual»**, sin garantía de ningún tipo, expresa o
implícita, incluidas las de comerciabilidad, idoneidad para un fin concreto y
ausencia de errores. En la medida en que lo permita la ley aplicable, el titular
no responde de ningún daño derivado del uso o de la imposibilidad de uso.

## 10. Finalidad exclusivamente educativa

**«Descubre con Lúa» no es un producto sanitario.** No evalúa, no diagnostica, no
criba, no trata y no sustituye a ningún profesional. No debe usarse para
tomar decisiones clínicas ni para valorar el desarrollo de ninguna criatura. Los
tiempos, actividades y sugerencias que ofrece son orientación pedagógica.

Usar la aplicación con una finalidad sanitaria **está fuera de esta licencia** y
es responsabilidad exclusiva de quien lo haga.

## 11. Incumplimiento

El uso fuera de lo autorizado extingue automáticamente los derechos concedidos
por esta licencia. Los derechos de uso personal y familiar se recuperan en
cuanto cesa el incumplimiento.

## 12. Ley aplicable

Esta licencia se rige por la **legislación española**, sin perjuicio de las
normas imperativas de protección del consumidor que correspondan a quien la
utilice.

## 13. Cambios en esta licencia

El titular puede publicar versiones nuevas. **Cada copia ya obtenida sigue
amparada por la versión que acompañaba a esa copia**: una versión nueva no
retira derechos ya concedidos sobre una instalación existente.

---

# License of «Descubre con Lúa · Edición Vigo» (English translation)

**Version 1.0 · 13 September 2026** · Rights holder: **Earlify Health S.L.**,
with Dr. Frank Alberto Betances Reinoso as author ·
**frank.alberto.betances.reinoso@gmail.com**

> **In one line.** Free forever for families and individuals. Institutions and
> businesses need a written licence.

**Free of charge, worldwide and indefinitely, for personal or family use** by a
natural person at home or with the children in their care, charging nobody and
acting on no organisation's behalf: install and use the app, read, study,
compile and privately modify the source, keep private backups, print the
printable materials for their own home.

**A prior written licence is required for institutional use** — any use by or on
behalf of a legal entity or public administration (nurseries, schools, town
councils, hospitals, clinics, associations, foundations, NGOs, universities,
training centres), **even when it is free of charge and even when the entity is
non-profit** — **and for commercial use**, meaning any use aimed at direct or
indirect economic gain. Write to the address above; terms are agreed case by
case and may include a free-of-charge grant.

**Never granted, in any case**: public redistribution; publishing the app or a
derivative on any app store; sublicensing, renting or assigning; removing or
altering credits, authorship or licence notices; passing the work off as one's
own; training machine-learning models for commercial purposes; or using the
names and marks «Descubre con Lúa», Lúa the cat, «Earlify Health» or the
author's crest to identify a third party's products or services.

**Third-party components keep their own licences** and fall outside this
document: the Nunito typeface (SIL OFL 1.1, `assets/fonts/OFL.txt`), Flutter,
Dart and their packages, and the Celtia, Sharvard and LJSpeech voice models,
which run only at build time and never on the device. The institutional logos
shown in the credits are their owners' marks and are not licensed here.

**No warranty.** The app is provided "as is", without warranty of any kind.

**Educational purpose only.** This is **not a medical device**: it does not
assess, diagnose, screen or treat, and it replaces no professional. Using it for
a health purpose falls outside this licence.

Governed by **Spanish law**.

*In case of discrepancy between the two versions, the Spanish text prevails.*
