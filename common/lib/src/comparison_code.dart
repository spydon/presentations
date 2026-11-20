import 'package:material_ui/material_ui.dart';
import 'package:common/src/brand.dart';
import 'package:common/src/slide_code.dart';

/// A labelled code listing, for one side of a before and after comparison.
class ComparisonCode extends StatelessWidget {
  const ComparisonCode({
    required this.label,
    required this.code,
    required this.isAfter,
    this.language = 'dart',
    this.visible = true,
    super.key,
  });

  final String label;
  final String code;
  final bool isAfter;
  final String language;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = isAfter ? Brand.green : Brand.red;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: visible ? 1 : 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          Row(
            children: [
              Icon(
                isAfter ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 40,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SlideCode(code: code, language: language, fontSize: 24),
        ],
      ),
    );
  }
}
