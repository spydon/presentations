import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupabaseLogo extends StatelessWidget {
  const SupabaseLogo({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/supabase_logo.svg',
      package: 'common',
      height: height,
      semanticsLabel: 'Supabase',
    );
  }
}
