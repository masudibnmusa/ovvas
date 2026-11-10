// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ovvas';

  @override
  String get tabToday => 'Today';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabWidgets => 'Widgets';

  @override
  String get tabSettings => 'Settings';

  @override
  String get addHabit => 'Add habit';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get savedOnPhoneOnly => 'Saved on this phone only';

  @override
  String get waitingForInternet => 'Waiting for internet';

  @override
  String get backupNeedsAttention => 'Backup hasn\'t run for 3 days';

  @override
  String get backedUpJustNow => 'Backed up just now';

  @override
  String backedUpAt(String time) {
    return 'Backed up at $time';
  }

  @override
  String get emptyTodayTitle => 'Start with one small habit';

  @override
  String get emptyTodayBody =>
      'Pick something easy you can do today. You can add more later.';

  @override
  String get addFirstHabit => 'Add your first habit';

  @override
  String ringSemantics(int done, int total) {
    return '$done of $total habits completed';
  }

  @override
  String doneOfTotal(int done, int total) {
    return '$done/$total';
  }

  @override
  String get completedLabel => 'completed';

  @override
  String get allDoneTitle => 'All done for today';

  @override
  String get allDoneBody => 'Lovely work. Rest well, see you tomorrow.';

  @override
  String habitsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits to go',
      one: '1 habit to go',
    );
    return '$_temp0';
  }

  @override
  String get yourHabits => 'Your habits';

  @override
  String get nothingScheduled =>
      'Nothing scheduled for this day. Enjoy the rest.';

  @override
  String editingDay(String date) {
    return 'Editing $date';
  }

  @override
  String get backToToday => 'Back to today';

  @override
  String get skippedForDay => 'Skipped for this day';

  @override
  String get readyToStartAgain => 'Ready to start again?';

  @override
  String get firstStepHint => 'Your first check-in starts the streak';

  @override
  String get doneLabel => 'Done';

  @override
  String progressOf(int value, int target, String unit) {
    return '$value/$target $unit';
  }

  @override
  String checkUndo(String name) {
    return '$name is done. Tap to undo.';
  }

  @override
  String checkAdd(int step, String name) {
    return 'Add $step to $name';
  }

  @override
  String checkUnskip(String name) {
    return '$name is skipped. Tap to unskip.';
  }

  @override
  String checkDo(String name) {
    return 'Mark $name as done';
  }

  @override
  String milestone(int days, String name) {
    return '$days-day streak on $name! Lovely consistency.';
  }

  @override
  String dayStreak(int days) {
    return '$days-day streak';
  }

  @override
  String get addNote => 'Add note';

  @override
  String get editNote => 'Edit note';

  @override
  String get skipDay => 'Skip this day';

  @override
  String get unskipDay => 'Unskip this day';

  @override
  String get skipHint => 'Won\'t break your streak or lower your rate';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get archiveHabit => 'Archive habit';

  @override
  String get restoreHabit => 'Restore habit';

  @override
  String get deleteHabit => 'Delete habit';

  @override
  String noteFor(String name) {
    return 'Note for $name';
  }

  @override
  String get noteHint => 'How did it go?';

  @override
  String habitArchived(String name) {
    return '$name archived';
  }

  @override
  String habitRestored(String name) {
    return '$name restored';
  }

  @override
  String get undo => 'Undo';

  @override
  String get unitMinutes => 'min';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get habitNotFound => 'This habit is no longer here.';

  @override
  String get moreActions => 'More actions';

  @override
  String bestStreak(int days) {
    return 'Best $days';
  }

  @override
  String get todayLabel => 'Today';

  @override
  String goalOf(int target, String unit) {
    return 'Goal: $target $unit';
  }

  @override
  String get completionRate => 'Completion rate';

  @override
  String get checkIns => 'Check-ins';

  @override
  String get bestDay => 'Best day';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get statusDone => 'Done';

  @override
  String get statusPartial => 'Partly done';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusMissed => 'Not done';

  @override
  String get statusNotDone => 'Not done';

  @override
  String get statusPending => 'Not yet';

  @override
  String get statusNotScheduled => 'Not scheduled';

  @override
  String get last8Weeks => 'Last 8 weeks';

  @override
  String get chartCaptionWeekly =>
      'Bars show the share of scheduled days completed each week.';

  @override
  String get chartCaptionDaily =>
      'Bars show the share of scheduled habits completed each day. Tap a bar for details.';

  @override
  String weekBarSemantics(String date, int done, int scheduled) {
    return 'Week of $date: $done of $scheduled days done';
  }

  @override
  String dayBarSemantics(String date, int done, int scheduled) {
    return '$date: $done of $scheduled habits done';
  }

  @override
  String get notes => 'Notes';

  @override
  String get noNotesYet =>
      'No notes yet. Long-press a habit on Today to add one.';

  @override
  String deleteHabitTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteHabitBody =>
      'This removes the habit and all its history. To keep the history, archive it instead.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get nameRequired => 'Give your habit a name';

  @override
  String get pickAtLeastOneDay => 'Pick at least one day';

  @override
  String get habitUpdated => 'Changes saved';

  @override
  String habitCreated(String name) {
    return '$name added';
  }

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'You have changes that aren\'t saved yet.';

  @override
  String get discard => 'Discard';

  @override
  String get newHabit => 'New habit';

  @override
  String get habitName => 'Habit name';

  @override
  String get habitNameHint => 'e.g. Drink water';

  @override
  String get iconAndColor => 'Choose an icon & color';

  @override
  String get goalType => 'Goal type';

  @override
  String get goalYesNo => 'Yes / No';

  @override
  String get goalCount => 'Count';

  @override
  String get goalTime => 'Time';

  @override
  String get goalPerDay => 'Goal per day';

  @override
  String get unit => 'Unit';

  @override
  String get unitHint => 'e.g. glasses, pages';

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatEveryDay => 'Every day';

  @override
  String get repeatSpecificDays => 'Some days';

  @override
  String get repeatPerWeek => 'Per week';

  @override
  String get timesPerWeekUnit => 'times per week';

  @override
  String get reminders => 'Reminders';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get addReminder => '+ Add reminder';

  @override
  String get remindersOff => 'Reminders are off for this habit.';

  @override
  String get moreOptions => 'More options';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get noEndDate => 'No end date';

  @override
  String get clearEndDate => 'Clear end date';

  @override
  String get note => 'Note';

  @override
  String get habitNoteHint => 'Why this habit matters to you';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveHabit => 'Save habit';

  @override
  String get suggestWater => 'Drink water';

  @override
  String get suggestRead => 'Read';

  @override
  String get suggestWalk => 'Take a walk';

  @override
  String get suggestMeditate => 'Meditate';

  @override
  String get suggestSleep => 'Sleep before 11';

  @override
  String get suggestNoSugar => 'No sugar';

  @override
  String get unitGlasses => 'glasses';

  @override
  String get unitPages => 'pages';

  @override
  String colorNumber(int number) {
    return 'Color $number';
  }

  @override
  String iconNumber(int number) {
    return 'Icon $number';
  }

  @override
  String get statsEmptyTitle => 'Your progress will show here';

  @override
  String get statsEmptyNoHabits =>
      'Add a habit and check in a few times to see your week and month.';

  @override
  String get statsEmptyPeriod =>
      'Nothing to show for this period yet. Check-ins will appear here.';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get jumpToToday => 'Today';

  @override
  String get vsLastWeek => 'vs last week';

  @override
  String get vsLastMonth => 'vs last month';

  @override
  String get summary => 'Summary';

  @override
  String get habitsCompleted => 'Habits completed';

  @override
  String get currentStreak => 'Current streak';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get perfectDays => 'Perfect days';

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get totalCheckIns => 'Total check-ins';

  @override
  String get byHabit => 'By habit';

  @override
  String insightBetterWeek(int percent) {
    return 'You did $percent% better than last week.';
  }

  @override
  String insightBetterMonth(int percent) {
    return 'You did $percent% better than last month.';
  }

  @override
  String insightHardestDay(String weekday) {
    return '${weekday}s are your hardest day.';
  }

  @override
  String get insightSteady => 'Steady as last time. Consistency is the habit.';

  @override
  String get insightKeepGoing => 'Every check-in counts. Keep going.';

  @override
  String get allHabits => 'All habits';

  @override
  String get noData => 'No data';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get perfectDay => 'All done';

  @override
  String doneOfScheduled(int done, int scheduled) {
    return '$done of $scheduled habits done';
  }

  @override
  String get trendSame => 'Same';

  @override
  String trendUp(int percent, String compared) {
    return 'Up $percent% $compared';
  }

  @override
  String trendDown(int percent, String compared) {
    return 'Down $percent% $compared';
  }

  @override
  String get yourWidgets => 'Your widgets';

  @override
  String get widgetsSubtitle => 'Your habits, your home screen.';

  @override
  String get livePreview => 'Live preview';

  @override
  String get preview => 'Preview';

  @override
  String get myWidgets => 'My widgets';

  @override
  String widgetsUsed(int used, int limit) {
    return '$used of $limit used';
  }

  @override
  String get chooseAWidget => 'Choose a widget';

  @override
  String get removeWidget => 'Remove widget';

  @override
  String get removeWidgetTitle => 'Remove this widget?';

  @override
  String get removeWidgetBody => 'Your habits and history stay safe.';

  @override
  String get remove => 'Remove';

  @override
  String get widgetLimitTitle => 'Widget limit reached';

  @override
  String widgetLimitBody(int limit) {
    return 'The free version includes $limit widgets with every option. Remove one to add another, or get Plus for unlimited widgets.';
  }

  @override
  String get widgetSingleHabit => 'Single habit';

  @override
  String get widgetSingleHabitDesc => 'One habit with a big check button';

  @override
  String get widgetTodayList => 'Today list';

  @override
  String get widgetTodayListDesc => 'Up to 3 or 6 habits with check buttons';

  @override
  String get widgetProgressRing => 'Progress ring';

  @override
  String get widgetProgressRingDesc => 'Today\'s completion at a glance';

  @override
  String get widgetWeekStrip => 'Week strip';

  @override
  String get widgetWeekStripDesc => 'Seven days with done dots';

  @override
  String get widgetMonthHeatmap => 'Month heatmap';

  @override
  String get widgetMonthHeatmapDesc => 'Calendar for one habit or all';

  @override
  String get widgetStreakCounter => 'Streak counter';

  @override
  String get widgetStreakCounterDesc => 'Current streak with a flame';

  @override
  String get widgetBuilder => 'Widget builder';

  @override
  String get widgetType => 'Widget type';

  @override
  String get widgetSizeLabel => 'Size';

  @override
  String sizeMedium(String grid) {
    return 'Medium $grid';
  }

  @override
  String sizeLarge(String grid) {
    return 'Large $grid';
  }

  @override
  String get habitsShown => 'Habits shown';

  @override
  String get widgetUsesAllHabits => 'This widget uses all of today\'s habits.';

  @override
  String widgetMaxHabits(int count) {
    return 'This size shows up to $count habits';
  }

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDevice => 'Device';

  @override
  String get themeAccent => 'Accent';

  @override
  String get background => 'Background';

  @override
  String get bgSolid => 'Solid';

  @override
  String get bgGradient => 'Gradient';

  @override
  String get bgTransparent => 'Transparent';

  @override
  String get opacity => 'Opacity';

  @override
  String get cornerRadius => 'Corner radius';

  @override
  String get cornerSquare => 'Square';

  @override
  String get cornerRounded => 'Rounded';

  @override
  String get cornerRound => 'Round';

  @override
  String get textSize => 'Text size';

  @override
  String get sizeS => 'Small';

  @override
  String get sizeM => 'Medium';

  @override
  String get sizeL => 'Large';

  @override
  String get showOnWidget => 'Show on widget';

  @override
  String get showTitle => 'Title';

  @override
  String get showStreak => 'Streak';

  @override
  String get showDate => 'Date';

  @override
  String get showPercentage => 'Percentage';

  @override
  String get tapAction => 'When tapped';

  @override
  String get tapCheck => 'Check habit';

  @override
  String get tapOpenToday => 'Open Today';

  @override
  String get tapOpenStats => 'Open Stats';

  @override
  String get weekStarts => 'Week starts on';

  @override
  String get contrastWarning =>
      'Text may be hard to read on some wallpapers. Try a higher opacity or another theme.';

  @override
  String get addToHomeScreen => 'Add to home screen';

  @override
  String get widgetSaved => 'Widget saved to My widgets';

  @override
  String get widgetUpdated => 'Widget updated';

  @override
  String get widgetPreviewSemantics => 'Widget preview';

  @override
  String get widgetPickHabit => 'Pick a habit';

  @override
  String get widgetNothingToday => 'Nothing scheduled today';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get accountAndBackup => 'Account & backup';

  @override
  String get yourName => 'Your name';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get backUpNow => 'Back up now';

  @override
  String get restore => 'Restore';

  @override
  String get exportData => 'Export file';

  @override
  String get exportFormats => 'PDF report';

  @override
  String get importData => 'Import file';

  @override
  String get exportSaved => 'Report saved';

  @override
  String get exportFailed => 'Couldn\'t create the file. Try again.';

  @override
  String get importConfirmTitle => 'Import from file?';

  @override
  String importConfirmMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits',
      one: '1 habit',
    );
    return '$_temp0 will be imported with their check-ins. Habits already on this phone are updated from the file. Nothing is deleted.';
  }

  @override
  String get importAction => 'Import';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits imported',
      one: '1 habit imported',
    );
    return '$_temp0';
  }

  @override
  String get importNotOvvas =>
      'This PDF wasn\'t exported from Ovvas, so there\'s nothing to import.';

  @override
  String get importFailed => 'Couldn\'t read the file. Try again.';

  @override
  String get availableWithCloud =>
      'This will work once cloud backup is connected.';

  @override
  String get defaultReminderTime => 'Default reminder time';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String get dailySummary => 'Daily summary';

  @override
  String get dailySummaryHint => '\"3 of 5 habits done today\"';

  @override
  String get weeklyReport => 'Weekly report';

  @override
  String get weeklyReportHint => 'Last week\'s rate and one insight';

  @override
  String get appearance => 'Appearance';

  @override
  String get textNormal => 'Normal';

  @override
  String get textLarge => 'Large';

  @override
  String get textExtraLarge => 'Extra large';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get haptics => 'Haptics';

  @override
  String get animations => 'Animations';

  @override
  String get celebrations => 'Milestone celebrations';

  @override
  String get celebrationsHint => 'At 7, 30, 100 and 365 days';

  @override
  String get habits => 'Habits';

  @override
  String get archivedHabits => 'Archived habits';

  @override
  String get noArchivedTitle => 'Nothing archived';

  @override
  String get noArchivedBody =>
      'Archived habits keep their history and can come back anytime.';

  @override
  String get plusTitle => 'Ovvas Plus';

  @override
  String get plusBody => 'Unlimited widgets. One-time or yearly. Never ads.';

  @override
  String get learnMore => 'Learn more';

  @override
  String get privacy => 'Privacy';

  @override
  String get whatWeStore => 'What we store';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get whatWeStoreIntro =>
      'Ovvas is built to keep your habits private. Here is everything the app keeps, and where.';

  @override
  String get storeOnPhoneTitle => 'On your phone';

  @override
  String get storeOnPhoneBody =>
      'Your habits, check-ins, notes, home screen widgets and settings, including the name you type in, are saved on this phone. The app works fully without an account or internet.';

  @override
  String get storeCloudTitle => 'In the cloud, only if you sign in';

  @override
  String get storeCloudBody =>
      'When you sign in, your habits, check-ins, notes and widget layouts are backed up to our server so you can restore them on another phone. Your settings and your name stay on this phone.';

  @override
  String get storeAccountTitle => 'Your account';

  @override
  String get storeAccountBody =>
      'Signing in with Google gives us your email address and basic profile (name and photo) to create your account. We never see your Google password.';

  @override
  String get storeNeverTitle => 'What we never collect';

  @override
  String get storeNeverBody =>
      'No ads, analytics, trackers or crash reporting. No location, contacts, photos, camera or microphone. Your data is never sold or shared.';

  @override
  String get storeExportTitle => 'Files you export';

  @override
  String get storeExportBody =>
      'Export file creates a PDF of your habits and history. It goes only where you save it, so anyone you share it with can read it.';

  @override
  String get readFullPolicy => 'Read the full privacy policy';

  @override
  String privacyUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyIntro =>
      'Ovvas is a habit tracker made to work without collecting your data. This policy explains what the app stores, why, and the choices you have.';

  @override
  String get policyCollectTitle => '1. Information we collect';

  @override
  String get policyCollectBody =>
      '• Without an account: nothing leaves your phone. Habits, check-ins, notes, widgets and settings are stored only on your device.\n• With an account: your email address and basic Google profile (name and photo), plus the habits, check-ins, notes and widget layouts you create.\n• We do not collect location, contacts, photos, device identifiers, usage analytics or advertising data.';

  @override
  String get policyUseTitle => '2. How we use it';

  @override
  String get policyUseBody =>
      'Only to run the app: to show your habits and stats, and, if you sign in, to back up your data and keep it in sync across your phones. We do not use your data for ads or profiling, and we do not read your notes.';

  @override
  String get policyStorageTitle =>
      '3. Where it is stored and how it is protected';

  @override
  String get policyStorageBody =>
      'Data on your phone stays in the app\'s private storage. Backups are stored with Supabase, our hosting provider. Data travels over encrypted connections (HTTPS), and access rules on the server make sure only your account can read or change your data.';

  @override
  String get policySharingTitle => '4. Sharing';

  @override
  String get policySharingBody =>
      'We never sell, rent or trade your data. We only rely on these services to run the app:\n• Supabase: account sign-in and backup storage.\n• Google: sign-in with your Google account.\n• Google Play or the App Store: payments for Ovvas Plus. We never see your card details.\nWe may disclose data only if the law requires it.';

  @override
  String get policyRetentionTitle => '5. Keeping and deleting your data';

  @override
  String get policyRetentionBody =>
      '• Data on your phone stays until you delete it or uninstall the app.\n• Backups are kept while your account exists.\n• Signing out stops backups but keeps the data on your phone.\n• Deleting your account removes the account and all backed-up data from our server.';

  @override
  String get policyChoicesTitle => '6. Your choices';

  @override
  String get policyChoicesBody =>
      'You can use Ovvas without an account, export your data as a PDF at any time, delete any habit and its history, sign out, or delete your account from Settings.';

  @override
  String get policyChildrenTitle => '7. Children';

  @override
  String get policyChildrenBody =>
      'Ovvas is not directed at children under 13, and we do not knowingly collect personal information from them.';

  @override
  String get policyChangesTitle => '8. Changes to this policy';

  @override
  String get policyChangesBody =>
      'If this policy changes, the new version will appear here with a new date. We will not start collecting new kinds of data without telling you first.';

  @override
  String get policyContactTitle => '9. Contact';

  @override
  String policyContactBody(String email) {
    return 'Questions about your privacy? Write to us at $email.';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'Your progress stays on this phone and in your backup.';

  @override
  String get deleteAccount => 'Delete my account and data';

  @override
  String get deleteAccountTitle => 'Delete account and data?';

  @override
  String get deleteAccountBody =>
      'This permanently removes your habits, check-ins, settings and backup from this phone and the cloud.';

  @override
  String versionLabel(String version) {
    return 'Ovvas $version';
  }

  @override
  String get noAdsPromise => 'No ads. No trackers. Ever.';

  @override
  String get signIn => 'Sign in with Google';

  @override
  String get signInHint => 'Back up your progress and restore it on any phone';

  @override
  String get signedOutMessage =>
      'Signed out. Your progress stays on this phone.';

  @override
  String get signedInMessage => 'Signed in. Backup is on.';

  @override
  String get signInFailed =>
      'Couldn\'t sign in. Check your internet and try again.';

  @override
  String get backupFailed =>
      'Couldn\'t back up. Check your internet and try again.';

  @override
  String get cloudNotConfigured =>
      'Cloud backup isn\'t set up in this version yet';
}
