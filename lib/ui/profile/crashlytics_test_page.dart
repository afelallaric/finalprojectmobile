import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashlyticsTestPage extends StatefulWidget {
  const CrashlyticsTestPage({super.key});

  @override
  State<CrashlyticsTestPage> createState() => _CrashlyticsTestPageState();
}

class _CrashlyticsTestPageState extends State<CrashlyticsTestPage> {
  bool _exceptionTriggered = false;
  bool _crashTriggered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crashlytics Test Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report_rounded,
                size: 80,
                color: colorScheme.error.withOpacity(0.8),
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase Crashlytics Test',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use these buttons to trigger exceptions and test if Crashlytics is successfully capturing and reporting crashes in the terminal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _exceptionTriggered
                    ? null
                    : () {
                        setState(() {
                          _exceptionTriggered = true;
                        });
                        throw const FormatException('Test Format Exception Triggered');
                      },
                icon: const Icon(Icons.error_outline_rounded),
                label: Text(_exceptionTriggered
                    ? 'Format Exception Triggered'
                    : 'Trigger Format Exception'),
                style: FilledButton.styleFrom(
                  backgroundColor: _exceptionTriggered ? colorScheme.surfaceVariant : colorScheme.error,
                  foregroundColor: _exceptionTriggered ? colorScheme.onSurfaceVariant : colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _crashTriggered
                    ? null
                    : () {
                        setState(() {
                          _crashTriggered = true;
                        });
                        FirebaseCrashlytics.instance.crash();
                      },
                icon: const Icon(Icons.flash_on_rounded),
                label: Text(_crashTriggered
                    ? 'Crash Triggered (Rebooting...)'
                    : 'Force Native Crash (instance.crash)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _crashTriggered ? colorScheme.onSurfaceVariant : colorScheme.error,
                  side: BorderSide(color: _crashTriggered ? colorScheme.outline : colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
