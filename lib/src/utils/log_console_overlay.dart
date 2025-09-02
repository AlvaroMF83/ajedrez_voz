import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // ← necesario para evitar errores en build
import 'logger.dart';

class LogConsoleOverlay extends StatefulWidget {
  final Widget child;
  const LogConsoleOverlay({super.key, required this.child});

  @override
  State<LogConsoleOverlay> createState() => _LogConsoleOverlayState();
}

class _LogConsoleOverlayState extends State<LogConsoleOverlay> {
  bool _open = false;

  void _onLogsChanged() {
    if (!mounted) return;
    // Deferimos el setState para no romper el build actual
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    AppLogger.I.addListener(_onLogsChanged);
  }

  @override
  void dispose() {
    AppLogger.I.removeListener(_onLogsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Botón flotante para abrir/cerrar consola
        Positioned(
          right: 12,
          bottom: 24,
          child: FloatingActionButton.small(
            onPressed: () => setState(() => _open = !_open),
            child: Icon(_open ? Icons.close : Icons.developer_mode),
          ),
        ),
        if (_open)
          Positioned(
            left: 8,
            right: 8,
            top: 40,
            bottom: 80,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.85),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Logs',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: AppLogger.I.lines.length,
                          itemBuilder: (_, i) => Text(
                            AppLogger.I.lines.elementAt(i),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
