import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/theme/habit_palette.dart';
import '../../data/habit_store.dart';
import '../../domain/widget_config.dart';
import '../common/components.dart';
import '../common/motion.dart';
import '../common/dialogs.dart';
import '../routes.dart';
import 'widget_labels.dart';
import 'widget_preview.dart';

/// Widget gallery: live preview, my widgets, and widget types to start from.
class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  WidgetConfig _newConfig(HabitStore store, WidgetKind kind, int firstWeekday) {
    final ids = store.habits.map((h) => h.id).toList();
    final habitIds = switch (kind.habitPick) {
      HabitPick.one => ids.take(1).toList(),
      HabitPick.many => ids.take(3).toList(),
      HabitPick.oneOrAll || HabitPick.all => <String>[],
    };
    return WidgetConfig(
      id: store.newWidgetId(),
      kind: kind,
      size: kind.sizes.first,
      habitIds: habitIds,
      firstWeekday: firstWeekday,
      tapAction: kind.canCheck ? WidgetTapAction.checkHabit : WidgetTapAction.openToday,
    );
  }

  Future<void> _create(BuildContext context, WidgetKind kind) async {
    final store = context.store;
    final l = context.l10n;
    if (!store.canAddWidget) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.widgetLimitTitle),
          content: Text(l.widgetLimitBody(HabitStore.freeWidgetLimit)),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok))],
        ),
      );
      return;
    }
    await openWidgetBuilder(context, _newConfig(store, kind, context.settings.firstWeekday), isNew: true);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final l = context.l10n;
    final c = context.colors;
    final widgets = store.widgets;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: staggered([
          Semantics(header: true, child: Text(l.yourWidgets, style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 4),
          Text(l.widgetsSubtitle, style: TextStyle(color: c.textSecondary)),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(l.livePreview, padding: const EdgeInsets.only(bottom: 12)),
                LayoutBuilder(
                  builder: (context, box) {
                    return Center(
                      child: WidgetPreview(
                        cellSize: (box.maxWidth / 4).clamp(56.0, 84.0),
                        config: widgets.isNotEmpty
                            ? widgets.first
                            : WidgetConfig(id: 'preview', kind: WidgetKind.todayList, size: WidgetSize.medium4x2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (widgets.isNotEmpty) ...[
            SectionLabel(
              l.myWidgets,
              trailing: store.isPlus
                  ? null
                  : Text(
                      l.widgetsUsed(widgets.length, HabitStore.freeWidgetLimit),
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
            ),
            for (final w in widgets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  onTap: () => openWidgetBuilder(context, w, isNew: false),
                  child: Row(
                    children: [
                      _KindIcon(kind: w.kind),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widgetKindName(context, w.kind), style: Theme.of(context).textTheme.titleMedium),
                            Text(w.size.label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.removeWidget,
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          final ok = await confirmAction(
                            context,
                            title: l.removeWidgetTitle,
                            message: l.removeWidgetBody,
                            confirmLabel: l.remove,
                            destructive: true,
                          );
                          if (ok) store.removeWidget(w.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
          SectionLabel(l.chooseAWidget),
          for (final kind in WidgetKind.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () => _create(context, kind),
                child: Row(
                  children: [
                    _KindIcon(kind: kind),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widgetKindName(context, kind), style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            widgetKindDescription(context, kind),
                            style: TextStyle(fontSize: 12, color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kind.sizes.map((s) => s.label).join(' · '),
                      style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _KindIcon extends StatelessWidget {
  const _KindIcon({required this.kind});

  final WidgetKind kind;

  @override
  Widget build(BuildContext context) {
    final accent = switch (kind) {
      WidgetKind.singleHabit => Accent.sky,
      WidgetKind.todayList => Accent.sky,
      WidgetKind.progressRing => Accent.violet,
      WidgetKind.weekStrip => Accent.amber,
      WidgetKind.monthHeatmap => Accent.rose,
      WidgetKind.streakCounter => Accent.coral,
    };
    return IconBadge(widgetKindIcon(kind), accent, size: 44);
  }
}
