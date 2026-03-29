import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tabs = [
      HomeScreen(strings: strings),
      _PlaceholderTab(title: strings.following),
      _PlaceholderTab(title: strings.alerts),
      _PlaceholderTab(title: strings.settings),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.sports_mma_outlined),
            label: strings.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_border),
            label: strings.following,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            label: strings.alerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: strings.settings,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
