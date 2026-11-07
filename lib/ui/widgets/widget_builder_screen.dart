import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/widget_config.dart';
import '../common/components.dart';
import '../common/format.dart';
import 'widget_labels.dart';
import 'widget_preview.dart';

/// Live preview at the top, options below. Every change shows instantly.
class WidgetBuilderScreen extends StatefulWidget {
  const WidgetBuilderScreen({super.key, required this.initial, required this.isNew});

  final WidgetConfig initial;
  final bool isNew;

  @override
  State<WidgetBuilderScreen> createState() => _WidgetBuilderScreenState();
}

class _WidgetBuilderScreenState extends State<WidgetBuilderScreen> {
  late WidgetConfig _config = widget.initial;

  void _set(WidgetConfig next) => setState(() => _config = next);

  void _setKind(WidgetKind kind) {
    final ids = context.store.habits.map((h) => h.id).toList();
    final current = _config.habitIds.isEmpty ? ids : _config.habitIds;
    _set(_config.copyWith(
      kind: kind,
      size: kind.sizes.first,
      habitIds: switch (kind.habitPick) {
        HabitPick.one => current.take(1).toList(),
        HabitPick.many => current.take(maxHabitsFor(kind.sizes.first)).toList(),
        HabitPick.oneOrAll || HabitPick.all => <String>[],
      },
      tapAction: kind.canCheck ? _config.tapAction : WidgetTapAction.openToday,
    ));
  }

  void _setSize(WidgetSize size) =>
      _set(_config.copyWith(size: size, habitIds: _config.habitIds.take(maxHabitsFor(size)).toList()));

  void _toggleHabit(String id) {
    final ids = [..._config.habitIds];
    switch (_config.kind.habitPick) {
      case HabitPick.one:
        _set(_config.copyWith(habitIds: [id]));
      case HabitPick.oneOrAll:
        _set(_config.copyWith(habitIds: ids.contains(id) ? [] : [id]));
      case HabitPick.many:
        if (ids.contains(id)) {
          ids.remove(id);
        } else if (ids.length < maxHabitsFor(_config.size)) {
          ids.add(id);
        } else {
          context.showSnack(context.l10n.widgetMaxHabits(maxHabitsFor(_config.size)));
          return;
        }
        _set(_config.copyWith(habitIds: ids));
      case HabitPick.all:
        break;
    }
  }

  void _save() {
    final l = context.l10n;
    context.store.saveWidget(_config);
    context.showSnack(widget.isNew ? l.widgetSaved : l.widgetUpdated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final p = WidgetPalette.resolve(context, _config.theme);
    final lowContrast = contrastRatio(p.foreground, effectiveWidgetBackground(_config, p)) < 4.5;
    final kind = _config.kind;

    return Scaffold(
      appBar: AppBar(title: Text(l.widgetBuilder)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _PreviewStage(config: _config),
          ),
          if (lowContrast)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: c.streak),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.contrastWarning, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                FieldLabel(l.widgetType),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in WidgetKind.values)
                      ChoiceChip(
                        avatar: Icon(widgetKindIcon(k), size: 18),
                        label: Text(widgetKindName(context, k)),
                        selected: k == kind,
                        onSelected: (_) => _setKind(k),
                      ),
                  ],
                ),
                if (kind.sizes.length > 1) ...[
                  FieldLabel(l.widgetSizeLabel),
                  PillSegmented<WidgetSize>(
                    value: _config.size,
                    options: [for (final s in kind.sizes) (s, s == WidgetSize.large4x4 ? l.sizeLarge(s.label) : l.sizeMedium(s.label))],
                    onChanged: _setSize,
                  ),
                ],
                if (kind.habitPick != HabitPick.all) ...[
                  FieldLabel(
                    l.habitsShown,
                    trailing: kind.habitPick == HabitPick.many
                        ? Text('${_config.habitIds.length}/${maxHabitsFor(_config.size)}', style: TextStyle(color: c.textSecondary))
                        : null,
                  ),
                  _HabitPicker(config: _config, onToggle: _toggleHabit, onAll: () => _set(_config.copyWith(habitIds: []))),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(l.widgetUsesAllHabits, style: TextStyle(color: c.textSecondary)),
                  ),
                FieldLabel(l.theme),
                _ThemeSwatches(value: _config.theme, onChanged: (t) => _set(_config.copyWith(theme: t))),
                FieldLabel(l.background),
                PillSegmented<WidgetBackground>(
                  value: _config.background,
                  options: [
                    (WidgetBackground.solid, l.bgSolid),
                    (WidgetBackground.gradient, l.bgGradient),
                    (WidgetBackground.transparent, l.bgTransparent),
                  ],
                  onChanged: (b) => _set(_config.copyWith(background: b, opacity: b == WidgetBackground.transparent ? 0.6 : 1)),
                ),
                if (_config.background == WidgetBackground.transparent)
                  Row(
                    children: [
                      Text(l.opacity),
                      Expanded(
                        child: Slider(
                          value: _config.opacity,
                          divisions: 20,
                          label: formatPercent(_config.opacity),
                          semanticFormatterCallback: formatPercent,
                          onChanged: (v) => _set(_config.copyWith(opacity: v)),
                        ),
                      ),
                      SizedBox(width: 48, child: Text(formatPercent(_config.opacity), textAlign: TextAlign.end)),
                    ],
                  ),
                FieldLabel(l.cornerRadius),
                PillSegmented<WidgetCorner>(
                  value: _config.corner,
                  options: [
                    (WidgetCorner.square, l.cornerSquare),
                    (WidgetCorner.rounded, l.cornerRounded),
                    (WidgetCorner.round, l.cornerRound),
                  ],
                  onChanged: (v) => _set(_config.copyWith(corner: v)),
                ),
                FieldLabel(l.textSize),
                PillSegmented<WidgetTextSize>(
                  value: _config.textSize,
                  options: [
                    (WidgetTextSize.small, l.sizeS),
                    (WidgetTextSize.medium, l.sizeM),
                    (WidgetTextSize.large, l.sizeL),
                  ],
                  onChanged: (v) => _set(_config.copyWith(textSize: v)),
                ),
                FieldLabel(l.showOnWidget),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(l.showTitle),
                        value: _config.showTitle,
                        onChanged: (v) => _set(_config.copyWith(showTitle: v)),
                      ),
                      SwitchListTile(
                        title: Text(l.showStreak),
                        value: _config.showStreak,
                        onChanged: (v) => _set(_config.copyWith(showStreak: v)),
                      ),
                      SwitchListTile(
                        title: Text(l.showDate),
                        value: _config.showDate,
                        onChanged: (v) => _set(_config.copyWith(showDate: v)),
                      ),
                      SwitchListTile(
                        title: Text(l.showPercentage),
                        value: _config.showPercentage,
                        onChanged: (v) => _set(_config.copyWith(showPercentage: v)),
                      ),
                    ],
                  ),
                ),
                FieldLabel(l.tapAction),
                PillSegmented<WidgetTapAction>(
                  value: _config.tapAction,
                  options: [
                    if (kind.canCheck) (WidgetTapAction.checkHabit, l.tapCheck),
                    (WidgetTapAction.openToday, l.tapOpenToday),
                    (WidgetTapAction.openStats, l.tapOpenStats),
                  ],
                  onChanged: (v) => _set(_config.copyWith(tapAction: v)),
                ),
                if (kind.usesWeekStart) ...[
                  FieldLabel(l.weekStarts),
                  PillSegmented<int>(
                    value: _config.firstWeekday,
                    options: [
                      (DateTime.monday, weekdayLong(context, DateTime.monday)),
                      (DateTime.sunday, weekdayLong(context, DateTime.sunday)),
                    ],
                    onChanged: (v) => _set(_config.copyWith(firstWeekday: v)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(onPressed: _save, child: Text(widget.isNew ? l.addToHomeScreen : l.saveChanges)),
        ),
      ),
    );
  }
}

/// A wallpaper-like backdrop so transparency and contrast look realistic.
class _PreviewStage extends StatelessWidget {
  const _PreviewStage({required this.config});

  final WidgetConfig config;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final maxCell = (box.maxWidth - 40) / 4;
      // Large widgets get a smaller cell so the options stay visible.
      final cell = (config.size.rows >= 4 ? maxCell * 0.62 : maxCell).clamp(44.0, 80.0);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8DB7A9), kWallpaperSample, Color(0xFF3D5866)],
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${context.l10n.preview.toUpperCase()} · ${widgetKindName(context, config.kind).toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.light.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSize(
              duration: context.motion(200),
              child: WidgetPreview(config: config, cellSize: cell),
            ),
          ],
        ),
      );
    });
  }
}

class _HabitPicker extends StatelessWidget {
  const _HabitPicker({required this.config, required this.onToggle, required this.onAll});

  final WidgetConfig config;
  final ValueChanged<String> onToggle;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final habits = context.store.habits;
    final pick = config.kind.habitPick;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (pick == HabitPick.oneOrAll)
          ChoiceChip(label: Text(context.l10n.allHabits), selected: config.habitIds.isEmpty, onSelected: (_) => onAll()),
        for (final h in habits)
          Builder(builder: (context) {
            final index = config.habitIds.indexOf(h.id);
            final selected = index >= 0;
            final label = pick == HabitPick.many && selected ? '${index + 1}. ${h.name}' : h.name;
            return pick == HabitPick.many
                ? FilterChip(
                    avatar: HabitAvatar.of(h, size: 24),
                    label: Text(label),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => onToggle(h.id),
                  )
                : ChoiceChip(
                    avatar: HabitAvatar.of(h, size: 24),
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => onToggle(h.id),
                  );
          }),
      ],
    );
  }
}

class _ThemeSwatches extends StatelessWidget {
  const _ThemeSwatches({required this.value, required this.onChanged});

  final WidgetTheme value;
  final ValueChanged<WidgetTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final items = <(WidgetTheme, String, Widget)>[
      (WidgetTheme.light, l.themeLight, _swatch(AppColors.light.surface)),
      (WidgetTheme.dark, l.themeDark, _swatch(AppColors.dark.surface)),
      (
        WidgetTheme.device,
        l.themeDevice,
        ClipOval(
          child: SizedBox.square(
            dimension: 40,
            child: Row(
              children: [
                Expanded(child: Container(color: AppColors.light.surface)),
                Expanded(child: Container(color: AppColors.dark.surface)),
              ],
            ),
          ),
        ),
      ),
      (WidgetTheme.accent, l.themeAccent, _swatch(c.primary)),
    ];
    return Row(
      children: [
        for (final (t, label, swatch) in items)
          Expanded(
            child: Semantics(
              button: true,
              selected: t == value,
              label: label,
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onChanged(t),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: t == value ? c.primary : Colors.transparent, width: 2.5),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.border)),
                          child: swatch,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(fontSize: 12, fontWeight: t == value ? FontWeight.w700 : FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _swatch(Color fill) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      );
}
