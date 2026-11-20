import 'package:material_ui/material_ui.dart';
import 'package:common/src/brand.dart';

/// A short green label in a rounded outline, with an optional icon.
class Pill extends StatelessWidget {
  const Pill({required this.text, this.icon, super.key});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Brand.green, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final icon?) ...[
            Icon(icon, color: Brand.green, size: 40),
            const SizedBox(width: 16),
          ],
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 36, color: Brand.green),
            ),
          ),
        ],
      ),
    );
  }
}
