import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BreakTimerSelector extends StatelessWidget {
  final int selectedDuration;
  final ValueChanged<int> onChanged;

  static const List<int> _options = [10, 30, 60];

  const BreakTimerSelector({
    super.key,
    required this.selectedDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTheme.scaleFactor(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _options.length; i++) ...[
          if (i > 0) SizedBox(width: 12 * scale),
          _buildPill(_options[i], scale),
        ],
      ],
    );
  }

  Widget _buildPill(int seconds, double scale) {
    final isSelected = seconds == selectedDuration;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Break length $seconds seconds',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(seconds);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: 64 * scale,
          height: 40 * scale,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.mauve.withValues(alpha: 0.20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(
              color: isSelected
                  ? AppTheme.mauve.withValues(alpha: 0.35)
                  : AppTheme.overlay1.withValues(alpha: 0.3),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.mauve.withValues(alpha: 0.08),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${seconds}s',
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w400,
              color: isSelected ? AppTheme.text : AppTheme.overlay1,
            ),
          ),
        ),
      ),
    );
  }
}
