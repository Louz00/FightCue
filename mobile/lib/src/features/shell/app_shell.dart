import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';

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
      _HomeTab(strings: strings),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(strings.appName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(strings.homeTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        const _HeroCard(),
        const SizedBox(height: 16),
        _InfoCard(text: strings.storeReadyNote),
        const SizedBox(height: 12),
        _InfoCard(text: strings.languageNote),
        const SizedBox(height: 12),
        _InfoCard(text: strings.sourceNote),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FightCue',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Cross-platform foundation for a timezone-first combat sports tracker.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
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
