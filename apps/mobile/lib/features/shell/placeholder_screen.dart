import 'package:material_ui/material_ui.dart';

/// Stands in for the screens you build later in the plan.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('$title comes later in the plan')),
  );
}
