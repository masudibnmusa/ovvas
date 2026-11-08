import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ovvas'**
  String get appName;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabWidgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get tabWidgets;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get addHabit;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @savedOnPhoneOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone only'**
  String get savedOnPhoneOnly;

  /// No description provided for @waitingForInternet.
  ///
  /// In en, this message translates to:
  /// **'Waiting for internet'**
  String get waitingForInternet;

  /// No description provided for @backupNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Backup hasn\'t run for 3 days'**
  String get backupNeedsAttention;

  /// No description provided for @backedUpJustNow.
  ///
  /// In en, this message translates to:
  /// **'Backed up just now'**
  String get backedUpJustNow;

  /// No description provided for @backedUpAt.
  ///
  /// In en, this message translates to:
  /// **'Backed up at {time}'**
  String backedUpAt(String time);

  /// No description provided for @emptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with one small habit'**
  String get emptyTodayTitle;

  /// No description provided for @emptyTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Pick something easy you can do today. You can add more later.'**
  String get emptyTodayBody;

  /// No description provided for @addFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Add your first habit'**
  String get addFirstHabit;

  /// No description provided for @ringSemantics.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} habits completed'**
  String ringSemantics(int done, int total);

  /// No description provided for @doneOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String doneOfTotal(int done, int total);

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completedLabel;

  /// No description provided for @yourHabits.
  ///
  /// In en, this message translates to:
  /// **'Your habits'**
  String get yourHabits;

  /// No description provided for @nothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for this day. Enjoy the rest.'**
  String get nothingScheduled;

  /// No description provided for @editingDay.
  ///
  /// In en, this message translates to:
  /// **'Editing {date}'**
  String editingDay(String date);

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get backToToday;

  /// No description provided for @skippedForDay.
  ///
  /// In en, this message translates to:
  /// **'Skipped for this day'**
  String get skippedForDay;

  /// No description provided for @readyToStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Ready to start again?'**
  String get readyToStartAgain;

  /// No description provided for @firstStepHint.
  ///
  /// In en, this message translates to:
  /// **'Your first check-in starts the streak'**
  String get firstStepHint;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @progressOf.
  ///
  /// In en, this message translates to:
  /// **'{value}/{target} {unit}'**
  String progressOf(int value, int target, String unit);

  /// No description provided for @checkUndo.
  ///
  /// In en, this message translates to:
  /// **'{name} is done. Tap to undo.'**
  String checkUndo(String name);

  /// No description provided for @checkAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {step} to {name}'**
  String checkAdd(int step, String name);

  /// No description provided for @checkUnskip.
  ///
  /// In en, this message translates to:
  /// **'{name} is skipped. Tap to unskip.'**
  String checkUnskip(String name);

  /// No description provided for @checkDo.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as done'**
  String checkDo(String name);

  /// No description provided for @milestone.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak on {name}! Lovely consistency.'**
  String milestone(int days, String name);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String dayStreak(int days);

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @skipDay.
  ///
  /// In en, this message translates to:
  /// **'Skip this day'**
  String get skipDay;

  /// No description provided for @unskipDay.
  ///
  /// In en, this message translates to:
  /// **'Unskip this day'**
  String get unskipDay;

  /// No description provided for @skipHint.
  ///
  /// In en, this message translates to:
  /// **'Won\'t break your streak or lower your rate'**
  String get skipHint;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @archiveHabit.
  ///
  /// In en, this message translates to:
  /// **'Archive habit'**
  String get archiveHabit;

  /// No description provided for @restoreHabit.
  ///
  /// In en, this message translates to:
  /// **'Restore habit'**
  String get restoreHabit;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get deleteHabit;

  /// No description provided for @noteFor.
  ///
  /// In en, this message translates to:
  /// **'Note for {name}'**
  String noteFor(String name);

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get noteHint;

  /// No description provided for @habitArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String habitArchived(String name);

  /// No description provided for @habitRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String habitRestored(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @habitNotFound.
  ///
  /// In en, this message translates to:
  /// **'This habit is no longer here.'**
  String get habitNotFound;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best {days}'**
  String bestStreak(int days);

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @goalOf.
  ///
  /// In en, this message translates to:
  /// **'Goal: {target} {unit}'**
  String goalOf(int target, String unit);

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion rate'**
  String get completionRate;

  /// No description provided for @checkIns.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get checkIns;

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDay;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly done'**
  String get statusPartial;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get statusMissed;

  /// No description provided for @statusNotDone.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get statusNotDone;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get statusPending;

  /// No description provided for @statusNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get statusNotScheduled;

  /// No description provided for @last8Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 8 weeks'**
  String get last8Weeks;

  /// No description provided for @chartCaptionWeekly.
  ///
  /// In en, this message translates to:
  /// **'Bars show the share of scheduled days completed each week.'**
  String get chartCaptionWeekly;

  /// No description provided for @chartCaptionDaily.
  ///
  /// In en, this message translates to:
  /// **'Bars show the share of scheduled habits completed each day. Tap a bar for details.'**
  String get chartCaptionDaily;

  /// No description provided for @weekBarSemantics.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}: {done} of {scheduled} days done'**
  String weekBarSemantics(String date, int done, int scheduled);

  /// No description provided for @dayBarSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}: {done} of {scheduled} habits done'**
  String dayBarSemantics(String date, int done, int scheduled);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Long-press a habit on Today to add one.'**
  String get noNotesYet;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteHabitTitle(String name);

  /// No description provided for @deleteHabitBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the habit and all its history. To keep the history, archive it instead.'**
  String get deleteHabitBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your habit a name'**
  String get nameRequired;

  /// No description provided for @pickAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get pickAtLeastOneDay;

  /// No description provided for @habitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get habitUpdated;

  /// No description provided for @habitCreated.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String habitCreated(String name);

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'You have changes that aren\'t saved yet.'**
  String get discardBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitName;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Drink water'**
  String get habitNameHint;

  /// No description provided for @iconAndColor.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon & color'**
  String get iconAndColor;

  /// No description provided for @goalType.
  ///
  /// In en, this message translates to:
  /// **'Goal type'**
  String get goalType;

  /// No description provided for @goalYesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get goalYesNo;

  /// No description provided for @goalCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get goalCount;

  /// No description provided for @goalTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get goalTime;

  /// No description provided for @goalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Goal per day'**
  String get goalPerDay;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. glasses, pages'**
  String get unitHint;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatEveryDay;

  /// No description provided for @repeatSpecificDays.
  ///
  /// In en, this message translates to:
  /// **'Some days'**
  String get repeatSpecificDays;

  /// No description provided for @repeatPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get repeatPerWeek;

  /// No description provided for @timesPerWeekUnit.
  ///
  /// In en, this message translates to:
  /// **'times per week'**
  String get timesPerWeekUnit;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'+ Add reminder'**
  String get addReminder;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off for this habit.'**
  String get remindersOff;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @clearEndDate.
  ///
  /// In en, this message translates to:
  /// **'Clear end date'**
  String get clearEndDate;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @habitNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Why this habit matters to you'**
  String get habitNoteHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveHabit.
  ///
  /// In en, this message translates to:
  /// **'Save habit'**
  String get saveHabit;

  /// No description provided for @suggestWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get suggestWater;

  /// No description provided for @suggestRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get suggestRead;

  /// No description provided for @suggestWalk.
  ///
  /// In en, this message translates to:
  /// **'Take a walk'**
  String get suggestWalk;

  /// No description provided for @suggestMeditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate'**
  String get suggestMeditate;

  /// No description provided for @suggestSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep before 11'**
  String get suggestSleep;

  /// No description provided for @suggestNoSugar.
  ///
  /// In en, this message translates to:
  /// **'No sugar'**
  String get suggestNoSugar;

  /// No description provided for @unitGlasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get unitGlasses;

  /// No description provided for @unitPages.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get unitPages;

  /// No description provided for @colorNumber.
  ///
  /// In en, this message translates to:
  /// **'Color {number}'**
  String colorNumber(int number);

  /// No description provided for @iconNumber.
  ///
  /// In en, this message translates to:
  /// **'Icon {number}'**
  String iconNumber(int number);

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress will show here'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyNoHabits.
  ///
  /// In en, this message translates to:
  /// **'Add a habit and check in a few times to see your week and month.'**
  String get statsEmptyNoHabits;

  /// No description provided for @statsEmptyPeriod.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show for this period yet. Check-ins will appear here.'**
  String get statsEmptyPeriod;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @jumpToToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get jumpToToday;

  /// No description provided for @vsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get vsLastWeek;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @habitsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Habits completed'**
  String get habitsCompleted;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @perfectDays.
  ///
  /// In en, this message translates to:
  /// **'Perfect days'**
  String get perfectDays;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @totalCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Total check-ins'**
  String get totalCheckIns;

  /// No description provided for @byHabit.
  ///
  /// In en, this message translates to:
  /// **'By habit'**
  String get byHabit;

  /// No description provided for @insightBetterWeek.
  ///
  /// In en, this message translates to:
  /// **'You did {percent}% better than last week.'**
  String insightBetterWeek(int percent);

  /// No description provided for @insightBetterMonth.
  ///
  /// In en, this message translates to:
  /// **'You did {percent}% better than last month.'**
  String insightBetterMonth(int percent);

  /// No description provided for @insightHardestDay.
  ///
  /// In en, this message translates to:
  /// **'{weekday}s are your hardest day.'**
  String insightHardestDay(String weekday);

  /// No description provided for @insightSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady as last time. Consistency is the habit.'**
  String get insightSteady;

  /// No description provided for @insightKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Every check-in counts. Keep going.'**
  String get insightKeepGoing;

  /// No description provided for @allHabits.
  ///
  /// In en, this message translates to:
  /// **'All habits'**
  String get allHabits;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @perfectDay.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get perfectDay;

  /// No description provided for @doneOfScheduled.
  ///
  /// In en, this message translates to:
  /// **'{done} of {scheduled} habits done'**
  String doneOfScheduled(int done, int scheduled);

  /// No description provided for @trendSame.
  ///
  /// In en, this message translates to:
  /// **'Same'**
  String get trendSame;

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'Up {percent}% {compared}'**
  String trendUp(int percent, String compared);

  /// No description provided for @trendDown.
  ///
  /// In en, this message translates to:
  /// **'Down {percent}% {compared}'**
  String trendDown(int percent, String compared);

  /// No description provided for @yourWidgets.
  ///
  /// In en, this message translates to:
  /// **'Your widgets'**
  String get yourWidgets;

  /// No description provided for @widgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your habits, your home screen.'**
  String get widgetsSubtitle;

  /// No description provided for @livePreview.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get livePreview;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @myWidgets.
  ///
  /// In en, this message translates to:
  /// **'My widgets'**
  String get myWidgets;

  /// No description provided for @widgetsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} used'**
  String widgetsUsed(int used, int limit);

  /// No description provided for @chooseAWidget.
  ///
  /// In en, this message translates to:
  /// **'Choose a widget'**
  String get chooseAWidget;

  /// No description provided for @removeWidget.
  ///
  /// In en, this message translates to:
  /// **'Remove widget'**
  String get removeWidget;

  /// No description provided for @removeWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this widget?'**
  String get removeWidgetTitle;

  /// No description provided for @removeWidgetBody.
  ///
  /// In en, this message translates to:
  /// **'Your habits and history stay safe.'**
  String get removeWidgetBody;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @widgetLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget limit reached'**
  String get widgetLimitTitle;

  /// No description provided for @widgetLimitBody.
  ///
  /// In en, this message translates to:
  /// **'The free version includes {limit} widgets with every option. Remove one to add another, or get Plus for unlimited widgets.'**
  String widgetLimitBody(int limit);

  /// No description provided for @widgetSingleHabit.
  ///
  /// In en, this message translates to:
  /// **'Single habit'**
  String get widgetSingleHabit;

  /// No description provided for @widgetSingleHabitDesc.
  ///
  /// In en, this message translates to:
  /// **'One habit with a big check button'**
  String get widgetSingleHabitDesc;

  /// No description provided for @widgetTodayList.
  ///
  /// In en, this message translates to:
  /// **'Today list'**
  String get widgetTodayList;

  /// No description provided for @widgetTodayListDesc.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 or 6 habits with check buttons'**
  String get widgetTodayListDesc;

  /// No description provided for @widgetProgressRing.
  ///
  /// In en, this message translates to:
  /// **'Progress ring'**
  String get widgetProgressRing;

  /// No description provided for @widgetProgressRingDesc.
  ///
  /// In en, this message translates to:
  /// **'Today\'s completion at a glance'**
  String get widgetProgressRingDesc;

  /// No description provided for @widgetWeekStrip.
  ///
  /// In en, this message translates to:
  /// **'Week strip'**
  String get widgetWeekStrip;

  /// No description provided for @widgetWeekStripDesc.
  ///
  /// In en, this message translates to:
  /// **'Seven days with done dots'**
  String get widgetWeekStripDesc;

  /// No description provided for @widgetMonthHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Month heatmap'**
  String get widgetMonthHeatmap;

  /// No description provided for @widgetMonthHeatmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Calendar for one habit or all'**
  String get widgetMonthHeatmapDesc;

  /// No description provided for @widgetStreakCounter.
  ///
  /// In en, this message translates to:
  /// **'Streak counter'**
  String get widgetStreakCounter;

  /// No description provided for @widgetStreakCounterDesc.
  ///
  /// In en, this message translates to:
  /// **'Current streak with a flame'**
  String get widgetStreakCounterDesc;

  /// No description provided for @widgetBuilder.
  ///
  /// In en, this message translates to:
  /// **'Widget builder'**
  String get widgetBuilder;

  /// No description provided for @widgetType.
  ///
  /// In en, this message translates to:
  /// **'Widget type'**
  String get widgetType;

  /// No description provided for @widgetSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get widgetSizeLabel;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium {grid}'**
  String sizeMedium(String grid);

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large {grid}'**
  String sizeLarge(String grid);

  /// No description provided for @habitsShown.
  ///
  /// In en, this message translates to:
  /// **'Habits shown'**
  String get habitsShown;

  /// No description provided for @widgetUsesAllHabits.
  ///
  /// In en, this message translates to:
  /// **'This widget uses all of today\'s habits.'**
  String get widgetUsesAllHabits;

  /// No description provided for @widgetMaxHabits.
  ///
  /// In en, this message translates to:
  /// **'This size shows up to {count} habits'**
  String widgetMaxHabits(int count);

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get themeDevice;

  /// No description provided for @themeAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get themeAccent;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @bgSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get bgSolid;

  /// No description provided for @bgGradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get bgGradient;

  /// No description provided for @bgTransparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get bgTransparent;

  /// No description provided for @opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// No description provided for @cornerRadius.
  ///
  /// In en, this message translates to:
  /// **'Corner radius'**
  String get cornerRadius;

  /// No description provided for @cornerSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get cornerSquare;

  /// No description provided for @cornerRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get cornerRounded;

  /// No description provided for @cornerRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get cornerRound;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @sizeS.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeS;

  /// No description provided for @sizeM.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sizeM;

  /// No description provided for @sizeL.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeL;

  /// No description provided for @showOnWidget.
  ///
  /// In en, this message translates to:
  /// **'Show on widget'**
  String get showOnWidget;

  /// No description provided for @showTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get showTitle;

  /// No description provided for @showStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get showStreak;

  /// No description provided for @showDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get showDate;

  /// No description provided for @showPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get showPercentage;

  /// No description provided for @tapAction.
  ///
  /// In en, this message translates to:
  /// **'When tapped'**
  String get tapAction;

  /// No description provided for @tapCheck.
  ///
  /// In en, this message translates to:
  /// **'Check habit'**
  String get tapCheck;

  /// No description provided for @tapOpenToday.
  ///
  /// In en, this message translates to:
  /// **'Open Today'**
  String get tapOpenToday;

  /// No description provided for @tapOpenStats.
  ///
  /// In en, this message translates to:
  /// **'Open Stats'**
  String get tapOpenStats;

  /// No description provided for @weekStarts.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStarts;

  /// No description provided for @contrastWarning.
  ///
  /// In en, this message translates to:
  /// **'Text may be hard to read on some wallpapers. Try a higher opacity or another theme.'**
  String get contrastWarning;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get addToHomeScreen;

  /// No description provided for @widgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Widget saved to My widgets'**
  String get widgetSaved;

  /// No description provided for @widgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Widget updated'**
  String get widgetUpdated;

  /// No description provided for @widgetPreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Widget preview'**
  String get widgetPreviewSemantics;

  /// No description provided for @widgetPickHabit.
  ///
  /// In en, this message translates to:
  /// **'Pick a habit'**
  String get widgetPickHabit;

  /// No description provided for @widgetNothingToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today'**
  String get widgetNothingToday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @accountAndBackup.
  ///
  /// In en, this message translates to:
  /// **'Account & backup'**
  String get accountAndBackup;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNow;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get exportData;

  /// No description provided for @exportFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get exportFormats;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get importData;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved'**
  String get exportSaved;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the file. Try again.'**
  String get exportFailed;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from file?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 habit} other{{count} habits}} will be imported with their check-ins. Habits already on this phone are updated from the file. Nothing is deleted.'**
  String importConfirmMessage(int count);

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 habit imported} other{{count} habits imported}}'**
  String importDone(int count);

  /// No description provided for @importNotOvvas.
  ///
  /// In en, this message translates to:
  /// **'This PDF wasn\'t exported from Ovvas, so there\'s nothing to import.'**
  String get importNotOvvas;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the file. Try again.'**
  String get importFailed;

  /// No description provided for @availableWithCloud.
  ///
  /// In en, this message translates to:
  /// **'This will work once cloud backup is connected.'**
  String get availableWithCloud;

  /// No description provided for @defaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Default reminder time'**
  String get defaultReminderTime;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get quietHours;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get dailySummary;

  /// No description provided for @dailySummaryHint.
  ///
  /// In en, this message translates to:
  /// **'\"3 of 5 habits done today\"'**
  String get dailySummaryHint;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get weeklyReport;

  /// No description provided for @weeklyReportHint.
  ///
  /// In en, this message translates to:
  /// **'Last week\'s rate and one insight'**
  String get weeklyReportHint;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @textNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textNormal;

  /// No description provided for @textLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textLarge;

  /// No description provided for @textExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textExtraLarge;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @celebrations.
  ///
  /// In en, this message translates to:
  /// **'Milestone celebrations'**
  String get celebrations;

  /// No description provided for @celebrationsHint.
  ///
  /// In en, this message translates to:
  /// **'At 7, 30, 100 and 365 days'**
  String get celebrationsHint;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @archivedHabits.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get archivedHabits;

  /// No description provided for @noArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get noArchivedTitle;

  /// No description provided for @noArchivedBody.
  ///
  /// In en, this message translates to:
  /// **'Archived habits keep their history and can come back anytime.'**
  String get noArchivedBody;

  /// No description provided for @plusTitle.
  ///
  /// In en, this message translates to:
  /// **'Ovvas Plus'**
  String get plusTitle;

  /// No description provided for @plusBody.
  ///
  /// In en, this message translates to:
  /// **'Unlimited widgets. One-time or yearly. Never ads.'**
  String get plusBody;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @whatWeStore.
  ///
  /// In en, this message translates to:
  /// **'What we store'**
  String get whatWeStore;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @whatWeStoreIntro.
  ///
  /// In en, this message translates to:
  /// **'Ovvas is built to keep your habits private. Here is everything the app keeps, and where.'**
  String get whatWeStoreIntro;

  /// No description provided for @storeOnPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'On your phone'**
  String get storeOnPhoneTitle;

  /// No description provided for @storeOnPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your habits, check-ins, notes, home screen widgets and settings, including the name you type in, are saved on this phone. The app works fully without an account or internet.'**
  String get storeOnPhoneBody;

  /// No description provided for @storeCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'In the cloud, only if you sign in'**
  String get storeCloudTitle;

  /// No description provided for @storeCloudBody.
  ///
  /// In en, this message translates to:
  /// **'When you sign in, your habits, check-ins, notes and widget layouts are backed up to our server so you can restore them on another phone. Your settings and your name stay on this phone.'**
  String get storeCloudBody;

  /// No description provided for @storeAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get storeAccountTitle;

  /// No description provided for @storeAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in with Google gives us your email address and basic profile (name and photo) to create your account. We never see your Google password.'**
  String get storeAccountBody;

  /// No description provided for @storeNeverTitle.
  ///
  /// In en, this message translates to:
  /// **'What we never collect'**
  String get storeNeverTitle;

  /// No description provided for @storeNeverBody.
  ///
  /// In en, this message translates to:
  /// **'No ads, analytics, trackers or crash reporting. No location, contacts, photos, camera or microphone. Your data is never sold or shared.'**
  String get storeNeverBody;

  /// No description provided for @storeExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Files you export'**
  String get storeExportTitle;

  /// No description provided for @storeExportBody.
  ///
  /// In en, this message translates to:
  /// **'Export file creates a PDF of your habits and history. It goes only where you save it, so anyone you share it with can read it.'**
  String get storeExportBody;

  /// No description provided for @readFullPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read the full privacy policy'**
  String get readFullPolicy;

  /// No description provided for @privacyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String privacyUpdated(String date);

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Ovvas is a habit tracker made to work without collecting your data. This policy explains what the app stores, why, and the choices you have.'**
  String get privacyIntro;

  /// No description provided for @policyCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Information we collect'**
  String get policyCollectTitle;

  /// No description provided for @policyCollectBody.
  ///
  /// In en, this message translates to:
  /// **'• Without an account: nothing leaves your phone. Habits, check-ins, notes, widgets and settings are stored only on your device.\n• With an account: your email address and basic Google profile (name and photo), plus the habits, check-ins, notes and widget layouts you create.\n• We do not collect location, contacts, photos, device identifiers, usage analytics or advertising data.'**
  String get policyCollectBody;

  /// No description provided for @policyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'2. How we use it'**
  String get policyUseTitle;

  /// No description provided for @policyUseBody.
  ///
  /// In en, this message translates to:
  /// **'Only to run the app: to show your habits and stats, and, if you sign in, to back up your data and keep it in sync across your phones. We do not use your data for ads or profiling, and we do not read your notes.'**
  String get policyUseBody;

  /// No description provided for @policyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Where it is stored and how it is protected'**
  String get policyStorageTitle;

  /// No description provided for @policyStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Data on your phone stays in the app\'s private storage. Backups are stored with Supabase, our hosting provider. Data travels over encrypted connections (HTTPS), and access rules on the server make sure only your account can read or change your data.'**
  String get policyStorageBody;

  /// No description provided for @policySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Sharing'**
  String get policySharingTitle;

  /// No description provided for @policySharingBody.
  ///
  /// In en, this message translates to:
  /// **'We never sell, rent or trade your data. We only rely on these services to run the app:\n• Supabase: account sign-in and backup storage.\n• Google: sign-in with your Google account.\n• Google Play or the App Store: payments for Ovvas Plus. We never see your card details.\nWe may disclose data only if the law requires it.'**
  String get policySharingBody;

  /// No description provided for @policyRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Keeping and deleting your data'**
  String get policyRetentionTitle;

  /// No description provided for @policyRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'• Data on your phone stays until you delete it or uninstall the app.\n• Backups are kept while your account exists.\n• Signing out stops backups but keeps the data on your phone.\n• Deleting your account removes the account and all backed-up data from our server.'**
  String get policyRetentionBody;

  /// No description provided for @policyChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Your choices'**
  String get policyChoicesTitle;

  /// No description provided for @policyChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'You can use Ovvas without an account, export your data as a PDF at any time, delete any habit and its history, sign out, or delete your account from Settings.'**
  String get policyChoicesBody;

  /// No description provided for @policyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Children'**
  String get policyChildrenTitle;

  /// No description provided for @policyChildrenBody.
  ///
  /// In en, this message translates to:
  /// **'Ovvas is not directed at children under 13, and we do not knowingly collect personal information from them.'**
  String get policyChildrenBody;

  /// No description provided for @policyChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'8. Changes to this policy'**
  String get policyChangesTitle;

  /// No description provided for @policyChangesBody.
  ///
  /// In en, this message translates to:
  /// **'If this policy changes, the new version will appear here with a new date. We will not start collecting new kinds of data without telling you first.'**
  String get policyChangesBody;

  /// No description provided for @policyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'9. Contact'**
  String get policyContactTitle;

  /// No description provided for @policyContactBody.
  ///
  /// In en, this message translates to:
  /// **'Questions about your privacy? Write to us at {email}.'**
  String policyContactBody(String email);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress stays on this phone and in your backup.'**
  String get signOutBody;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account and data'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account and data?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your habits, check-ins, settings and backup from this phone and the cloud.'**
  String get deleteAccountBody;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Ovvas {version}'**
  String versionLabel(String version);

  /// No description provided for @noAdsPromise.
  ///
  /// In en, this message translates to:
  /// **'No ads. No trackers. Ever.'**
  String get noAdsPromise;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signIn;

  /// No description provided for @signInHint.
  ///
  /// In en, this message translates to:
  /// **'Back up your progress and restore it on any phone'**
  String get signInHint;

  /// No description provided for @signedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Signed out. Your progress stays on this phone.'**
  String get signedOutMessage;

  /// No description provided for @signedInMessage.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Backup is on.'**
  String get signedInMessage;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Check your internet and try again.'**
  String get signInFailed;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t back up. Check your internet and try again.'**
  String get backupFailed;

  /// No description provided for @cloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup isn\'t set up in this version yet'**
  String get cloudNotConfigured;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
