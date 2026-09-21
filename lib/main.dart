import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CounterImageToggleApp());
}

/// Root widget. Owns the theme mode so the single MaterialApp can switch
/// between light and dark (the starter code nested a second MaterialApp
/// inside HomePage, which works but rebuilds the whole app tree).
class CounterImageToggleApp extends StatefulWidget {
  const CounterImageToggleApp({super.key});

  @override
  State<CounterImageToggleApp> createState() => _CounterImageToggleAppState();
}

class _CounterImageToggleAppState extends State<CounterImageToggleApp> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 Counter & Toggle',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: HomePage(isDark: _isDark, onToggleTheme: _toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const int _maxHistory = 5;
  static const int _colorRampEnd = 50; // counter value where color is fully red

  // ---- State ----
  int _counter = 0;
  int _step = 1;
  bool _isFirstImage = true;
  final List<int> _history = []; // previous counter values, newest last

  // ---- Animation ----
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      value: 1.0, // start fully visible (starter code started at 0 = invisible)
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _loadState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---- Persistence (graduate task) ----
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _isFirstImage = prefs.getBool('isFirstImage') ?? true;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
    await prefs.setBool('isFirstImage', _isFirstImage);
  }

  // ---- Counter logic ----
  void _setCounter(int newValue) {
    setState(() {
      _history.add(_counter);
      if (_history.length > _maxHistory) _history.removeAt(0);
      _counter = newValue;
    });
    _saveState();
  }

  void _increment() => _setCounter(_counter + _step);

  void _decrement() => _setCounter(math.max(0, _counter - _step));

  void _undo() {
    if (_history.isEmpty) return;
    setState(() => _counter = _history.removeLast());
    _saveState();
  }

  // ---- Image toggle with fade-out, swap, fade-in ----
  Future<void> _toggleImage() async {
    if (_controller.isAnimating) return; // ignore taps mid-transition
    await _controller.reverse(); // fade out current image
    if (!mounted) return;
    setState(() => _isFirstImage = !_isFirstImage); // swap while invisible
    _saveState();
    await _controller.forward(); // fade in new image
  }

  // ---- Reset with confirmation (graduate task) ----
  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must choose a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text(
            'Are you sure you want to clear all data? This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed == true) await _resetApp();
  }

  Future<void> _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // make the reset permanent
    if (!mounted) return;
    setState(() {
      _counter = 0;
      _step = 1;
      _isFirstImage = true;
      _history.clear();
    });
    _controller.value = 1.0;
  }

  // ---- UI ----
  Color get _counterColor {
    final t = (_counter / _colorRampEnd).clamp(0.0, 1.0);
    return Color.lerp(Colors.green, Colors.red, t)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CW1 Counter & Toggle'),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Counter: $_counter',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _counterColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text('Step: +$_step',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('+1')),
                  ButtonSegment(value: 5, label: Text('+5')),
                  ButtonSegment(value: 10, label: Text('+10')),
                ],
                selected: {_step},
                onSelectionChanged: (s) => setState(() => _step = s.first),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _counter > 0 ? _decrement : null,
                    child: const Text('Decrement'),
                  ),
                  ElevatedButton(
                    onPressed: _increment,
                    child: const Text('Increment'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _history.isEmpty ? null : _undo,
                    icon: const Icon(Icons.undo),
                    label: Text('Undo (${_history.length})'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _isFirstImage ? 'assets/image1.png' : 'assets/image2.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    // Placeholder so the app never crashes on a missing asset.
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      width: 180,
                      height: 180,
                      child: Icon(
                        _isFirstImage ? Icons.wb_sunny : Icons.nightlight_round,
                        size: 96,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _toggleImage,
                child: const Text('Toggle Image'),
              ),
              const SizedBox(height: 28),
              // Distinct reset control (graduate task).
              OutlinedButton.icon(
                onPressed: _showResetDialog,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
