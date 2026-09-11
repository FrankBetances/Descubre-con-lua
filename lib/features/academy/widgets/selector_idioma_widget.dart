import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';

/// Bilingual language toggle widget (`GL` / `ES`) for pedagogical modules.
///
/// Designed with adult-focused, accessible Material 3 styling (high contrast,
/// clear typography, zero distracting animations or child mechanics).
class SelectorIdiomaWidget extends StatelessWidget {
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final bool compact;

  const SelectorIdiomaWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context: context,
            lang: AppLanguage.gl,
            label: compact ? 'GL' : 'Galego',
            isSelected: currentLanguage == AppLanguage.gl,
          ),
          const SizedBox(width: 2.0),
          _buildLanguageOption(
            context: context,
            lang: AppLanguage.es,
            label: compact ? 'ES' : 'Castellano',
            isSelected: currentLanguage == AppLanguage.es,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required AppLanguage lang,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        if (!isSelected) {
          onLanguageChanged(lang);
        }
      },
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8.0 : 12.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryVigoBlue : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: compact ? 13.0 : 14.0,
          ),
        ),
      ),
    );
  }
}
