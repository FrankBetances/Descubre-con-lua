import 'package:flutter/foundation.dart';

/// O-20261111-4: registro de licencias de terceros en Flutter (`LicenseRegistry`).
///
/// Las fuentes originales viven solo en compilación (`tools/banco/`), pero las
/// láminas vectoriales o raster empaquetadas en `assets/brand/laminas/` derivan
/// de ellas y deben quedar acreditadas en el diálogo legal del sistema.
void registrarLicenzasTerceiros() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Microsoft Fluent Emoji (Flat)'],
      'MIT License\n\n'
      'Copyright (c) Microsoft Corporation.\n'
      'Origin: microsoft/fluentui-emoji (assets/*/Flat, commit 1ffb34c752ecf5d402f04cfb4b392c77f57c54bc).\n\n'
      'Permission is hereby granted, free of charge, to any person obtaining a copy '
      'of this software and associated documentation files (the "Software"), to deal '
      'in the Software without restriction, including without limitation the rights '
      'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
      'copies of the Software, and to permit persons to whom the Software is '
      'furnished to do so, subject to the following conditions:\n\n'
      'The above copyright notice and this permission notice shall be included in all '
      'copies or substantial portions of the Software.\n\n'
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
      'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
      'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.',
    );
    yield const LicenseEntryWithLineBreaks(
      ['Iconify Icon Sets (MIT / Apache 2.0 / CC0)'],
      'Iconify (@iconify/json, commit 81ad501f19cc13e548e4cb6a9c63a3873c87262a).\n'
      'Solo sets con licencia compatible con uso comercial y obras derivadas:\n'
      '- Fluent UI System Icons (Microsoft Corporation) · MIT\n'
      '- Tabler Icons (Paweł Kuna) · MIT\n'
      '- Health Icons (Resolve to Save Lives) · MIT / CC0 1.0\n'
      '- Material Symbols / Material Design Icons (Google / Pictogrammers) · Apache 2.0\n'
      '- Noto Emoji (Google Inc) · Apache 2.0',
    );
    yield const LicenseEntryWithLineBreaks(
      ['Game Icons (game-icons.net)'],
      'Creative Commons Attribution 3.0 Unported (CC BY 3.0).\n'
      'Origin: game-icons/icons via Iconify (commit 81ad501f19cc13e548e4cb6a9c63a3873c87262a).\n'
      'Icons made by GameIcons contributors (Lorc, Delapouite, Skoll, sbed, etc.; '
      'author recorded per piece in ATTRIBUTION.md and palabras_laminas.json).',
    );
    yield const LicenseEntryWithLineBreaks(
      ['Vocabulary Flashcard Dataset (dnizfor)'],
      'MIT License\n\n'
      'Copyright (c) 2026 Dnizfor\n'
      'Origin: dnizfor/vocabulary-flashcard-dataset (commit eae41b7c6cd85da0ca4171ce79eb115971b533de).\n\n'
      'Permission is hereby granted, free of charge, to any person obtaining a copy '
      'of this software and associated documentation files (the "Software"), to deal '
      'in the Software without restriction.',
    );
    yield const LicenseEntryWithLineBreaks(
      ['PB Image Bank (Pratham Books / StoryWeaver)'],
      'Creative Commons Attribution 4.0 International (CC BY 4.0).\n'
      'Origin: global-asp/pb-imagebank (commit 7f6a3b2d0213e05c25a088413a487178a4209234).\n'
      'Used strictly for support scenes, with per-illustrator credit in ATTRIBUTION.md.',
    );
  });
}
