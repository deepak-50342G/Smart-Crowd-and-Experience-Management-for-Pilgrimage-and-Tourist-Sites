import 'package:material_ui/material_ui.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/login_background.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        const ColoredBox(color: Color.fromRGBO(248, 249, 253, 0.82)),
        child,
      ],
    );
  }
}

class AuthContentCard extends StatelessWidget {
  const AuthContentCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.95)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(37, 33, 55, 0.05),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
