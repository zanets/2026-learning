import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _subnetCtrl;
  late TextEditingController _nmapCtrl;
  bool _saved = false;
  String? _nmapStatus;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _subnetCtrl = TextEditingController(text: settings.subnet);
    _nmapCtrl = TextEditingController(text: settings.nmapPath);
  }

  @override
  void dispose() {
    _subnetCtrl.dispose();
    _nmapCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).save(
          settings.copyWith(
            subnet: _subnetCtrl.text.trim(),
            nmapPath: _nmapCtrl.text.trim(),
          ),
        );
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  Future<void> _verifyNmap() async {
    setState(() {
      _verifying = true;
      _nmapStatus = null;
    });
    try {
      final result = await Process.run(_nmapCtrl.text.trim(), ['--version']);
      final output = result.stdout.toString();
      if (output.contains('Nmap') || output.contains('nmap')) {
        final versionLine = output.split('\n').first.trim();
        setState(() => _nmapStatus = '✓ $versionLine');
      } else {
        setState(() => _nmapStatus = '✗ Unexpected output');
      }
    } catch (e) {
      setState(() => _nmapStatus = '✗ Not found: $e');
    } finally {
      setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final currentLocale = settings.localeCode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Language ────────────────────────────────────────────────────
          _SectionHeader(icon: Icons.language, title: l10n.language),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Row(
              children: [
                _LangButton(
                  label: l10n.english,
                  selected: currentLocale == 'en' || currentLocale == null,
                  onTap: () =>
                      ref.read(settingsProvider.notifier).updateLocale('en'),
                ),
                const SizedBox(width: 8),
                _LangButton(
                  label: l10n.chinese,
                  selected: currentLocale == 'zh',
                  onTap: () =>
                      ref.read(settingsProvider.notifier).updateLocale('zh'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Network Settings ────────────────────────────────────────────
          _SectionHeader(icon: Icons.wifi, title: l10n.networkSettings),
          const SizedBox(height: 8),
          _SettingsCard(
            child: TextField(
              controller: _subnetCtrl,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'monospace'),
              decoration: InputDecoration(
                labelText: l10n.subnet,
                hintText: l10n.subnetHint,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── nmap Path ───────────────────────────────────────────────────
          const _SectionHeader(icon: Icons.terminal, title: 'nmap'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              children: [
                TextField(
                  controller: _nmapCtrl,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: l10n.nmapPath,
                    hintText: l10n.nmapPathHint,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _verifying ? null : _verifyNmap,
                      icon: _verifying
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(l10n.verifyNmap),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_nmapStatus != null)
                      Expanded(
                        child: Text(
                          _nmapStatus!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _nmapStatus!.startsWith('✓')
                                ? AppColors.success
                                : AppColors.danger,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Save button ─────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: _save,
            icon: Icon(_saved ? Icons.check : Icons.save_outlined, size: 18),
            label: Text(_saved ? l10n.settingsSaved : l10n.saveSettings),
            style: FilledButton.styleFrom(
              backgroundColor: _saved ? AppColors.success : AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
