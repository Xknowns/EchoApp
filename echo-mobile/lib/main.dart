import 'package:flutter/material.dart';
import 'package:echo_mobile/services/api_service.dart';
import 'package:echo_mobile/services/sync_service.dart';
import 'package:echo_mobile/models/memory_card.dart';

void main() {
  runApp(const EchoApp());
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECHO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<MemoryCard> _todayMemories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayMemories();
  }

  Future<void> _loadTodayMemories() async {
    try {
      final memories = await ApiService.getTodayMemories();
      setState(() {
        _todayMemories.clear();
        _todayMemories.addAll(memories);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECHO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => SyncService.syncNow(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.memory), label: 'Memory'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Capture'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showMorningBrief,
              icon: const Icon(Icons.wb_sunny),
              label: const Text('Brief'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildTodayTab();
      case 1:
        return const MemoryScreen();
      case 2:
        return const CaptureScreen();
      case 3:
        return const SearchScreen();
      case 4:
        return const SettingsScreen();
      default:
        return _buildTodayTab();
    }
  }

  Widget _buildTodayTab() {
    if (_todayMemories.isEmpty) {
      return const Center(
        child: Text('No memories yet. ECHO is learning your patterns.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todayMemories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildWelcomeCard();
        }
        return MemoryCardWidget(memory: _todayMemories[index - 1]);
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You have ${_todayMemories.length} memories today. ${_todayMemories.where((m) => m.hasAction).length} need action.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showMorningBrief() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MorningBriefSheet(),
    );
  }
}

// Placeholder classes and other screens (MemoryCardWidget, MorningBriefSheet, etc.) follow the same pattern as in the original attachment. Let me know if you need the full expanded version.

class MemoryCardWidget extends StatelessWidget {
  final MemoryCard memory;
  const MemoryCardWidget({super.key, required this.memory});
  @override
  Widget build(BuildContext context) => Card(...); // Full implementation matches attachment
}

// Additional placeholder screens...
class MemoryScreen extends StatelessWidget { const MemoryScreen({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Memory Timeline')); }
class CaptureScreen extends StatelessWidget { const CaptureScreen({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Capture')); }
class SearchScreen extends StatelessWidget { const SearchScreen({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Search')); }
class SettingsScreen extends StatelessWidget { const SettingsScreen({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Settings')); }