import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../ui/widgets.dart';
import 'providers.dart';
import 'theme.dart';

/// Locks the app on start and after it has been in the background longer
/// than [relockAfter] (rule R5). Uses the device's fingerprint/face or PIN.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  static const relockAfter = Duration(seconds: 30);

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> {
  final _auth = LocalAuthentication();
  late final AppLifecycleListener _lifecycle;
  bool _locked = true;
  bool _busy = false;
  String? _error;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _backgroundedAt = DateTime.now(),
      onShow: () {
        final at = _backgroundedAt;
        if (at != null &&
            DateTime.now().difference(at) > LockGate.relockAfter &&
            _lockEnabled) {
          setState(() => _locked = true);
          _unlock();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _lockEnabled =>
      ref.read(settingProvider(SettingKeys.lockEnabled)).value != 'false';

  Future<void> _unlock() async {
    if (_busy) return;
    final setting =
        await ref.read(databaseProvider).getValue(SettingKeys.lockEnabled);
    if (setting == 'false') {
      if (mounted) setState(() => _locked = false);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        // No screen lock set on the phone: nothing to check against.
        setState(() => _locked = false);
        return;
      }
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock Card Master',
        persistAcrossBackgrounding: true,
      );
      setState(() {
        _locked = !ok;
        if (!ok) _error = 'Not unlocked. Try again.';
      });
    } catch (e) {
      setState(() => _error = 'Unlock failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      if (_locked)
        Positioned.fill(
          child: Material(
            color: AppColors.background,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 96, 32, 40),
                child: Column(children: [
                  const BrandMark(size: 140),
                  const SizedBox(height: 18),
                  const StackedWordmark(),
                  const SizedBox(height: 10),
                  const Text(
                    'Your cards, their perks, and the best card for every spend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    iconSize: 44,
                    padding: const EdgeInsets.all(20),
                    tooltip: 'Unlock',
                    onPressed: _busy ? null : _unlock,
                    icon: const Icon(Icons.fingerprint),
                  ),
                  const SizedBox(height: 14),
                  Text(_error ?? 'Unlock with fingerprint, face or PIN',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _error == null
                              ? AppColors.textPrimary
                              : AppColors.dangerText)),
                  const SizedBox(height: 28),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_outlined,
                          size: 16, color: AppColors.earned),
                      SizedBox(width: 8),
                      Text('Your data stays encrypted on this phone',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}
