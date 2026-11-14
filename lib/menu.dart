import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String npm = '2506637086';
  static const String fullName = 'Muhammad Reyhan Attarizky';
  static const String pbpClass = 'PBP KI';
  static const double maxContentWidth = 600;

  static final List<ItemHomepage> items = [
    ItemHomepage(
      name: 'View Education',
      icon: Icons.school,
      color: Colors.blue.shade800,
      tooltip: 'Browse my education history',
    ),
    ItemHomepage(
      name: 'Add Education',
      icon: Icons.add_circle,
      color: Colors.green.shade800,
      tooltip: 'Add a new education entry',
    ),
    ItemHomepage(
      name: 'Logout',
      icon: Icons.logout,
      color: Colors.red.shade800,
      tooltip: 'Log out of MyPortfolio',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              children: [
                const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InfoCard(title: 'NPM', content: npm),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Name', content: fullName),
                      ),
                      Expanded(
                        child: InfoCard(title: 'Class', content: pbpClass),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Text(
                    'Welcome to MyPortfolio Mobile!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  children: [for (final item in items) ItemCard(item)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
