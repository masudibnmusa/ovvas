import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../domain/dates.dart';
import '../../domain/habit.dart';
import '../common/components.dart';
import '../common/motion.dart';
import '../common/dialogs.dart';
import '../common/format.dart';

/// Create or edit a habit. Essentials first, advanced options folded away.
class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key, this.habit});

  /// Null when creating a new habit.
  final Habit? habit;

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _note;
  late int _icon;
  late int _color;
  late GoalType _goal;
  late int _target;
  late RepeatKind _repeat;
  late Set<int> _weekdays;
  late int _timesPerWeek;
  late List<ReminderTime> _reminders;
  late DateTime _start;
  DateTime? _end;

  /// Once the user picks an icon or color we stop auto-suggesting.
  bool _styleChosen = false;
  bool _dirty = false;
  String? _nameError;

  bool get _isEdit => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _name = TextEditingController(text: h?.name ?? '');
    _unit = TextEditingController(text: h?.unit ?? '');
    _note = TextEditingController(text: h?.note ?? '');
    _icon = h?.iconIndex ?? 0;
    _color = h?.colorIndex ?? 0;
    _goal = h?.goalType ?? GoalType.yesNo;
    _target = h?.target ?? 1;
    _repeat = h?.repeat ?? RepeatKind.everyDay;
    _weekdays = {...(h?.weekdays ?? Habit.allWeekdays)};
    _timesPerWeek = h?.timesPerWeek ?? 3;
    _reminders = [...?h?.reminders];
    _start = h?.startDate ?? DateTime.now();
    _end = h?.endDate;
    _styleChosen = h != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _note.dispose();
    super.dispose();
  }

  void _edit(VoidCallback change) => setState(() {
    change();
    _dirty = true;
  });

  void _onNameChanged(String value) => _edit(() {
    _nameError = null;
    if (!_styleChosen) {
      final s = suggestStyle(value);
      if (s != null) {
        _icon = s.icon;
        _color = s.color;
      }
    }
  });

  void _applySuggestion(_Suggestion s) => _edit(() {
    _name.text = s.name;
    _nameError = null;
    _goal = s.goal;
    _target = s.target;
    _unit.text = s.unit;
    final style = suggestStyle(s.key);
    if (style != null && !_styleChosen) {
      _icon = style.icon;
      _color = style.color;
    }
  });

  void _setGoal(GoalType g) => _edit(() {
    _goal = g;
    _target = switch (g) {
      GoalType.yesNo => 1,
      GoalType.count => _target < 2 ? 8 : _target,
      GoalType.time => _target < 5 ? 15 : _target,
    };
  });

  Future<void> _addReminder() async {
    final d = context.settings.defaultReminder;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: d.hour, minute: d.minute),
    );
    if (picked == null) return;
    final t = ReminderTime(picked.hour, picked.minute);
    if (_reminders.contains(t)) return;
    _edit(() => _reminders = [..._reminders, t]..sort());
  }

  Future<void> _pickDate({required bool start}) async {
    final today = context.store.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _start : (_end ?? addDays(today, 30)),
      firstDate: start ? addDays(today, -365) : _start,
      lastDate: addDays(today, 3650),
    );
    if (picked == null) return;
    _edit(() {
      if (start) {
        _start = picked;
        if (_end != null && _end!.isBefore(_start)) _end = null;
      } else {
        _end = picked;
      }
    });
  }

  void _save() {
    final l = context.l10n;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l.nameRequired);
      return;
    }
    if (_repeat == RepeatKind.weekdays && _weekdays.isEmpty) {
      context.showSnack(l.pickAtLeastOneDay);
      return;
    }
    final store = context.store;
    final habit = Habit(
      id: widget.habit?.id ?? store.newId(),
      name: name,
      iconIndex: _icon,
      colorIndex: _color,
      goalType: _goal,
      target: _goal == GoalType.yesNo ? 1 : _target,
      unit: _goal == GoalType.count ? _unit.text.trim() : '',
      repeat: _repeat,
      weekdays: _weekdays,
      timesPerWeek: _timesPerWeek,
      reminders: _reminders,
      startDate: dateOnly(_start),
      endDate: _end == null ? null : dateOnly(_end!),
      note: _note.text.trim(),
      archived: widget.habit?.archived ?? false,
    );
    _isEdit ? store.updateHabit(habit) : store.addHabit(habit);
    _dirty = false;
    context.showSnack(_isEdit ? l.habitUpdated : l.habitCreated(name));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final h = widget.habit!;
    final ok = await confirmAction(
      context,
      title: l.deleteHabitTitle(h.name),
      message: l.deleteHabitBody,
      confirmLabel: l.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final store = context.store;
    Navigator.of(context).popUntil((r) => r.isFirst);
    store.deleteHabit(h.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final settings = context.settings;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final leave = await confirmAction(
          context,
          title: l.discardTitle,
          message: l.discardBody,
          confirmLabel: l.discard,
          destructive: true,
        );
        if (leave) {
          _dirty = false;
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEdit ? l.editHabit : l.newHabit)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: staggered([
            FieldLabel(l.habitName),
            TextField(
              controller: _name,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l.habitNameHint, errorText: _nameError),
              onChanged: _onNameChanged,
            ),
            if (!_isEdit && _name.text.isEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _suggestions(context))
                    ActionChip(
                      pressElevation: 0,
                      avatar: Icon(Icons.add_rounded, size: 18, color: c.primary),
                      label: Text(s.name),
                      onPressed: () => _applySuggestion(s),
                    ),
                ],
              ),
            ],
            FieldLabel(
              l.iconAndColor,
              trailing: HabitAvatar(iconIndex: _icon, colorIndex: _color, size: 40),
            ),
            _ColorPicker(
              selected: _color,
              onSelected: (i) => _edit(() {
                _color = i;
                _styleChosen = true;
              }),
            ),
            const SizedBox(height: 12),
            _IconPicker(
              selected: _icon,
              colorIndex: _color,
              onSelected: (i) => _edit(() {
                _icon = i;
                _styleChosen = true;
              }),
            ),
            FieldLabel(l.goalType),
            PillSegmented<GoalType>(
              value: _goal,
              options: [(GoalType.yesNo, l.goalYesNo), (GoalType.count, l.goalCount), (GoalType.time, l.goalTime)],
              onChanged: _setGoal,
            ),
            if (_goal != GoalType.yesNo) ...[
              FieldLabel(l.goalPerDay),
              CountStepper(
                value: _target,
                min: _goal == GoalType.time ? 5 : 1,
                step: _goal == GoalType.time ? 5 : 1,
                unit: _goal == GoalType.time ? l.unitMinutes : (_unit.text.isEmpty ? null : _unit.text),
                onChanged: (v) => _edit(() => _target = v),
              ),
              if (_goal == GoalType.count) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _unit,
                  decoration: InputDecoration(labelText: l.unit, hintText: l.unitHint),
                  onChanged: (_) => _edit(() {}),
                ),
              ],
            ],
            FieldLabel(l.repeat),
            PillSegmented<RepeatKind>(
              value: _repeat,
              options: [
                (RepeatKind.everyDay, l.repeatEveryDay),
                (RepeatKind.weekdays, l.repeatSpecificDays),
                (RepeatKind.timesPerWeek, l.repeatPerWeek),
              ],
              onChanged: (r) => _edit(() => _repeat = r),
            ),
            if (_repeat == RepeatKind.weekdays) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < 7; i++)
                    Builder(
                      builder: (context) {
                        final w = weekdayAt(i, settings.firstWeekday);
                        return FilterChip(
                          label: Text(weekdayShort(context, w)),
                          selected: _weekdays.contains(w),
                          onSelected: (on) => _edit(() => on ? _weekdays.add(w) : _weekdays.remove(w)),
                        );
                      },
                    ),
                ],
              ),
            ],
            if (_repeat == RepeatKind.timesPerWeek) ...[
              const SizedBox(height: 12),
              CountStepper(
                value: _timesPerWeek,
                min: 1,
                max: 6,
                unit: l.timesPerWeekUnit,
                onChanged: (v) => _edit(() => _timesPerWeek = v),
              ),
            ],
            FieldLabel(l.reminders),
            if (_reminders.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _reminders)
                    InputChip(
                      avatar: Icon(Icons.notifications_none_rounded, size: 18, color: c.onMint),
                      label: Text(formatTime(context, t)),
                      deleteButtonTooltipMessage: l.removeReminder,
                      onDeleted: () => _edit(() => _reminders = [..._reminders]..remove(t)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: Material(
                color: c.surfaceMuted,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _addReminder,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l.addReminder,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            if (_reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.remindersOff, style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(l.moreOptions, style: Theme.of(context).textTheme.titleMedium),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_rounded),
                    title: Text(l.startDate),
                    subtitle: Text(formatLongDate(context, _start)),
                    onTap: () => _pickDate(start: true),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_busy_rounded),
                    title: Text(l.endDate),
                    subtitle: Text(_end == null ? l.noEndDate : formatLongDate(context, _end!)),
                    onTap: () => _pickDate(start: false),
                    trailing: _end == null
                        ? null
                        : IconButton(
                            tooltip: l.clearEndDate,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => _edit(() => _end = null),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _note,
                    minLines: 2,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l.note, hintText: l.habitNoteHint),
                    onChanged: (_) => _edit(() {}),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  final h = widget.habit!;
                  context.store.setArchived(h.id, !h.archived);
                  context.showSnack(h.archived ? l.habitRestored(h.name) : l.habitArchived(h.name));
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                icon: const Icon(Icons.archive_outlined),
                label: Text(widget.habit!.archived ? l.restoreHabit : l.archiveHabit),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: c.danger),
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l.deleteHabit),
              ),
            ],
          ]),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(onPressed: _save, child: Text(_isEdit ? l.saveChanges : l.saveHabit)),
          ),
        ),
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion(this.key, this.name, this.goal, this.target, this.unit);

  /// English keyword used for icon matching.
  final String key;
  final String name;
  final GoalType goal;
  final int target;
  final String unit;
}

List<_Suggestion> _suggestions(BuildContext context) {
  final l = context.l10n;
  return [
    _Suggestion('water', l.suggestWater, GoalType.count, 8, l.unitGlasses),
    _Suggestion('read', l.suggestRead, GoalType.count, 10, l.unitPages),
    _Suggestion('walk', l.suggestWalk, GoalType.yesNo, 1, ''),
    _Suggestion('meditate', l.suggestMeditate, GoalType.time, 10, ''),
    _Suggestion('sleep', l.suggestSleep, GoalType.yesNo, 1, ''),
    _Suggestion('sugar', l.suggestNoSugar, GoalType.yesNo, 1, ''),
  ];
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < kHabitColors.length; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: l.colorNumber(i + 1),
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => onSelected(i),
              radius: 24,
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: AnimatedScale(
                    scale: i == selected ? 1.12 : 1,
                    duration: context.motion(Motion.base),
                    curve: Motion.pop,
                    child: AnimatedContainer(
                      duration: context.motion(Motion.base),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habitTint(context, i).background,
                        border: Border.all(
                          color: i == selected ? c.primary : habitTint(context, i).foreground.withValues(alpha: 0.35),
                          width: i == selected ? 3 : 1.5,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: context.motion(Motion.base),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: i == selected
                            ? Icon(
                                Icons.check_rounded,
                                key: const ValueKey(true),
                                size: 18,
                                color: habitTint(context, i).foreground,
                              )
                            : const SizedBox.shrink(key: ValueKey(false)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({required this.selected, required this.colorIndex, required this.onSelected});

  final int selected;
  final int colorIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final tint = habitTint(context, colorIndex);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < kHabitIcons.length; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: l.iconNumber(i + 1),
            excludeSemantics: true,
            child: Pressable(
              scale: 0.9,
              child: AnimatedScale(
                scale: i == selected ? 1.08 : 1,
                duration: context.motion(Motion.base),
                curve: Motion.pop,
                child: Material(
                  animationDuration: context.motion(Motion.base),
                  color: i == selected ? tint.background : c.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: i == selected ? c.primary : c.border, width: i == selected ? 2 : 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onSelected(i),
                    child: SizedBox.square(
                      dimension: 48,
                      child: Icon(kHabitIcons[i], color: i == selected ? tint.foreground : c.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
