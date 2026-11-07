import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/settings_controller.dart';
import '../../domain/habit.dart';
import '../common/components.dart';
import '../common/dialogs.dart';
import '../common/format.dart';
import '../today/today_screen.dart' show SyncChip;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<ReminderTime?> _pickTime(BuildContext context, ReminderTime initial) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute));
    return t == null ? null : ReminderTime(t.hour, t.minute);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final s = context.settings;
    final l = context.l10n;
    final c = context.colors;
    void soon() => context.showSnack(l.availableWithCloud);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Semantics(header: true, child: Text(l.tabSettings, style: Theme.of(context).textTheme.headlineSmall)),

          // Account and backup
          SectionLabel(l.accountAndBackup),
          _Group(children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: c.mint,
                child: Text(
                  s.userName.isEmpty ? '?' : s.userName.characters.first.toUpperCase(),
                  style: TextStyle(color: c.onMint, fontWeight: FontWeight.w700),
                ),
              ),
              title: Text(s.userName.isEmpty ? l.yourName : s.userName),
              subtitle: Text(store.signedIn ? store.accountEmail : l.notSignedIn),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () async {
                final name = await askText(context, title: l.yourName, initial: s.userName, maxLines: 1);
                if (name != null) s.userName = name;
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(alignment: AlignmentDirectional.centerStart, child: SyncChip()),
            ),
            if (store.signedIn)
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: Text(l.backUpNow),
                onTap: () {
                  store.backUpNow();
                  context.showSnack(l.backedUpJustNow);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login_rounded),
                title: Text(l.signIn),
                subtitle: Text(l.signInHint),
                onTap: () {
                  store.signIn();
                  context.showSnack(l.signedInMessage);
                },
              ),
            ListTile(leading: const Icon(Icons.restore_rounded), title: Text(l.restore), onTap: soon),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: Text(l.exportData),
              subtitle: Text(l.exportFormats),
              onTap: soon,
            ),
            ListTile(leading: const Icon(Icons.file_upload_outlined), title: Text(l.importData), onTap: soon),
          ]),

          // Reminders
          SectionLabel(l.reminders),
          _Group(children: [
            ListTile(
              leading: const Icon(Icons.alarm_rounded),
              title: Text(l.defaultReminderTime),
              trailing: Text(formatTime(context, s.defaultReminder), style: TextStyle(color: c.textSecondary)),
              onTap: () async {
                final t = await _pickTime(context, s.defaultReminder);
                if (t != null) s.defaultReminder = t;
              },
            ),
            ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: Text(l.quietHours),
              subtitle: Text('${formatTime(context, s.quietStart)} – ${formatTime(context, s.quietEnd)}'),
              onTap: () async {
                final start = await _pickTime(context, s.quietStart);
                if (start == null || !context.mounted) return;
                final end = await _pickTime(context, s.quietEnd);
                if (end == null) return;
                s.quietStart = start;
                s.quietEnd = end;
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.summarize_outlined),
              title: Text(l.dailySummary),
              subtitle: Text(l.dailySummaryHint),
              value: s.dailySummary,
              onChanged: (v) => s.dailySummary = v,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.insights_outlined),
              title: Text(l.weeklyReport),
              subtitle: Text(l.weeklyReportHint),
              value: s.weeklyReport,
              onChanged: (v) => s.weeklyReport = v,
            ),
          ]),

          // Appearance
          SectionLabel(l.appearance),
          _Group(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.theme, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              PillSegmented<ThemeMode>(
                value: s.themeMode,
                options: [
                  (ThemeMode.system, l.themeDevice),
                  (ThemeMode.light, l.themeLight),
                  (ThemeMode.dark, l.themeDark),
                ],
                onChanged: (v) => s.themeMode = v,
              ),
              const SizedBox(height: 20),
              Text(l.textSize, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              PillSegmented<double>(
                value: s.textScale,
                options: [
                  (SettingsController.textScales[0], l.textNormal),
                  (SettingsController.textScales[1], l.textLarge),
                  (SettingsController.textScales[2], l.textExtraLarge),
                ],
                onChanged: (v) => s.textScale = v,
              ),
            ],
          ),

          // Preferences
          SectionLabel(l.preferences),
          _Group(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.language, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    PillSegmented<String>(
                      value: s.locale.languageCode,
                      options: const [('en', 'English'), ('bn', 'বাংলা')],
                      onChanged: (v) => s.locale = Locale(v),
                    ),
                    const SizedBox(height: 20),
                    Text(l.weekStarts, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    PillSegmented<int>(
                      value: s.firstWeekday,
                      options: [
                        (DateTime.monday, weekdayLong(context, DateTime.monday)),
                        (DateTime.sunday, weekdayLong(context, DateTime.sunday)),
                      ],
                      onChanged: (v) => s.firstWeekday = v,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration_rounded),
                title: Text(l.haptics),
                value: s.haptics,
                onChanged: (v) => s.haptics = v,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.animation_rounded),
                title: Text(l.animations),
                value: s.animations,
                onChanged: (v) => s.animations = v,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.celebration_outlined),
                title: Text(l.celebrations),
                subtitle: Text(l.celebrationsHint),
                value: s.celebrations,
                onChanged: (v) => s.celebrations = v,
              ),
            ],
          ),

          // Habits
          SectionLabel(l.habits),
          _Group(children: [
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(l.archivedHabits),
              trailing: Text('${store.archivedHabits.length}', style: TextStyle(color: c.textSecondary)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArchivedHabitsScreen())),
            ),
          ]),

          // Plus: one quiet card.
          const SizedBox(height: 24),
          AppCard(
            color: c.mint,
            child: Row(
              children: [
                Icon(Icons.spa_rounded, color: c.onMint, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.plusTitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.onMint)),
                      const SizedBox(height: 2),
                      Text(l.plusBody, style: TextStyle(color: c.onMint, fontSize: 14)),
                    ],
                  ),
                ),
                TextButton(onPressed: soon, child: Text(l.learnMore)),
              ],
            ),
          ),

          // Privacy
          SectionLabel(l.privacy),
          _Group(children: [
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l.whatWeStore),
              onTap: () => showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.whatWeStore),
                  content: Text(l.whatWeStoreBody),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok))],
                ),
              ),
            ),
            ListTile(leading: const Icon(Icons.policy_outlined), title: Text(l.privacyPolicy), onTap: soon),
            if (store.signedIn)
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(l.signOut),
                onTap: () async {
                  final ok = await confirmAction(context, title: l.signOutTitle, message: l.signOutBody, confirmLabel: l.signOut);
                  if (!ok || !context.mounted) return;
                  store.signOut();
                  context.showSnack(l.signedOutMessage);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: c.danger),
              title: Text(l.deleteAccount, style: TextStyle(color: c.danger)),
              onTap: () async {
                final ok = await confirmAction(
                  context,
                  title: l.deleteAccountTitle,
                  message: l.deleteAccountBody,
                  confirmLabel: l.delete,
                  destructive: true,
                );
                if (ok) soon();
              },
            ),
          ]),
          const SizedBox(height: 24),
          Center(child: Text(l.versionLabel('1.0.0'), style: TextStyle(color: c.textSecondary, fontSize: 12))),
          const SizedBox(height: 4),
          Center(child: Text(l.noAdsPromise, style: TextStyle(color: c.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }
}

/// Settings rows grouped on one card.
class _Group extends StatelessWidget {
  const _Group({required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

/// Archived habits keep their history and can be restored.
class ArchivedHabitsScreen extends StatelessWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l = context.l10n;
    final habits = store.archivedHabits;
    return Scaffold(
      appBar: AppBar(title: Text(l.archivedHabits)),
      body: habits.isEmpty
          ? Center(
              child: EmptyState(icon: Icons.archive_outlined, title: l.noArchivedTitle, message: l.noArchivedBody),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final h in habits)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      child: Row(
                        children: [
                          HabitAvatar.of(h, size: 40),
                          const SizedBox(width: 12),
                          Expanded(child: Text(h.name, style: Theme.of(context).textTheme.titleMedium)),
                          TextButton(
                            onPressed: () {
                              store.setArchived(h.id, false);
                              context.showSnack(l.habitRestored(h.name));
                            },
                            child: Text(l.restore),
                          ),
                          IconButton(
                            tooltip: l.deleteHabit,
                            icon: Icon(Icons.delete_outline_rounded, color: context.colors.danger),
                            onPressed: () async {
                              final ok = await confirmAction(
                                context,
                                title: l.deleteHabitTitle(h.name),
                                message: l.deleteHabitBody,
                                confirmLabel: l.delete,
                                destructive: true,
                              );
                              if (ok) store.deleteHabit(h.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
