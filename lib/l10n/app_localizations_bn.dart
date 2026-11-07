// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'হ্যাবিটো';

  @override
  String get tabToday => 'আজ';

  @override
  String get tabStats => 'পরিসংখ্যান';

  @override
  String get tabWidgets => 'উইজেট';

  @override
  String get tabSettings => 'সেটিংস';

  @override
  String get addHabit => 'অভ্যাস যোগ করুন';

  @override
  String greetingMorning(String name) {
    return 'শুভ সকাল, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'শুভ অপরাহ্ন, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'শুভ সন্ধ্যা, $name';
  }

  @override
  String get savedOnPhoneOnly => 'শুধু এই ফোনে সংরক্ষিত';

  @override
  String get waitingForInternet => 'ইন্টারনেটের অপেক্ষায়';

  @override
  String get backupNeedsAttention => '৩ দিন ধরে ব্যাকআপ হয়নি';

  @override
  String get backedUpJustNow => 'এইমাত্র ব্যাকআপ হয়েছে';

  @override
  String backedUpAt(String time) {
    return '$time-এ ব্যাকআপ হয়েছে';
  }

  @override
  String get emptyTodayTitle => 'একটি ছোট অভ্যাস দিয়ে শুরু করুন';

  @override
  String get emptyTodayBody =>
      'আজই করা যায় এমন সহজ কিছু বেছে নিন। পরে আরও যোগ করতে পারবেন।';

  @override
  String get addFirstHabit => 'প্রথম অভ্যাস যোগ করুন';

  @override
  String ringSemantics(int done, int total) {
    return '$totalটির মধ্যে $doneটি অভ্যাস সম্পন্ন';
  }

  @override
  String doneOfTotal(int done, int total) {
    return '$done/$total';
  }

  @override
  String get completedLabel => 'সম্পন্ন';

  @override
  String get yourHabits => 'আপনার অভ্যাস';

  @override
  String get nothingScheduled =>
      'এই দিনে কিছু নির্ধারিত নেই। বিশ্রাম উপভোগ করুন।';

  @override
  String editingDay(String date) {
    return '$date সম্পাদনা করছেন';
  }

  @override
  String get backToToday => 'আজকে ফিরুন';

  @override
  String get skippedForDay => 'এই দিনের জন্য বাদ দেওয়া';

  @override
  String get readyToStartAgain => 'আবার শুরু করতে প্রস্তুত?';

  @override
  String get firstStepHint => 'প্রথম চেক-ইনেই স্ট্রিক শুরু';

  @override
  String get doneLabel => 'সম্পন্ন';

  @override
  String progressOf(int value, int target, String unit) {
    return '$value/$target $unit';
  }

  @override
  String checkUndo(String name) {
    return '$name সম্পন্ন। ফেরাতে ট্যাপ করুন।';
  }

  @override
  String checkAdd(int step, String name) {
    return '$name-এ $step যোগ করুন';
  }

  @override
  String checkUnskip(String name) {
    return '$name বাদ দেওয়া। আবার চালু করতে ট্যাপ করুন।';
  }

  @override
  String checkDo(String name) {
    return '$name সম্পন্ন হিসেবে চিহ্নিত করুন';
  }

  @override
  String milestone(int days, String name) {
    return '$name-এ $days দিনের স্ট্রিক! দারুণ ধারাবাহিকতা।';
  }

  @override
  String dayStreak(int days) {
    return '$days দিনের স্ট্রিক';
  }

  @override
  String get addNote => 'নোট যোগ করুন';

  @override
  String get editNote => 'নোট সম্পাদনা';

  @override
  String get skipDay => 'এই দিনটি বাদ দিন';

  @override
  String get unskipDay => 'বাদ দেওয়া বাতিল করুন';

  @override
  String get skipHint => 'স্ট্রিক ভাঙবে না, হারও কমবে না';

  @override
  String get editHabit => 'অভ্যাস সম্পাদনা';

  @override
  String get archiveHabit => 'অভ্যাস আর্কাইভ করুন';

  @override
  String get restoreHabit => 'অভ্যাস ফিরিয়ে আনুন';

  @override
  String get deleteHabit => 'অভ্যাস মুছুন';

  @override
  String noteFor(String name) {
    return '$name-এর নোট';
  }

  @override
  String get noteHint => 'কেমন গেল?';

  @override
  String habitArchived(String name) {
    return '$name আর্কাইভ হয়েছে';
  }

  @override
  String habitRestored(String name) {
    return '$name ফিরিয়ে আনা হয়েছে';
  }

  @override
  String get undo => 'ফেরান';

  @override
  String get unitMinutes => 'মিনিট';

  @override
  String get decrease => 'কমান';

  @override
  String get increase => 'বাড়ান';

  @override
  String get habitNotFound => 'এই অভ্যাসটি আর নেই।';

  @override
  String get moreActions => 'আরও অপশন';

  @override
  String bestStreak(int days) {
    return 'সেরা $days';
  }

  @override
  String get todayLabel => 'আজ';

  @override
  String goalOf(int target, String unit) {
    return 'লক্ষ্য: $target $unit';
  }

  @override
  String get completionRate => 'সম্পন্নের হার';

  @override
  String get checkIns => 'চেক-ইন';

  @override
  String get bestDay => 'সেরা দিন';

  @override
  String get previousMonth => 'আগের মাস';

  @override
  String get nextMonth => 'পরের মাস';

  @override
  String get previousWeek => 'আগের সপ্তাহ';

  @override
  String get nextWeek => 'পরের সপ্তাহ';

  @override
  String get statusDone => 'সম্পন্ন';

  @override
  String get statusPartial => 'আংশিক';

  @override
  String get statusSkipped => 'বাদ';

  @override
  String get statusMissed => 'হয়নি';

  @override
  String get statusNotDone => 'হয়নি';

  @override
  String get statusPending => 'এখনও না';

  @override
  String get statusNotScheduled => 'নির্ধারিত নয়';

  @override
  String get last8Weeks => 'শেষ ৮ সপ্তাহ';

  @override
  String get chartCaptionWeekly =>
      'প্রতি সপ্তাহে নির্ধারিত দিনের কত অংশ সম্পন্ন হয়েছে।';

  @override
  String get chartCaptionDaily =>
      'প্রতিদিন নির্ধারিত অভ্যাসের কত অংশ সম্পন্ন। বিস্তারিত দেখতে বারে ট্যাপ করুন।';

  @override
  String weekBarSemantics(String date, int done, int scheduled) {
    return '$date সপ্তাহ: $scheduled দিনের মধ্যে $done দিন সম্পন্ন';
  }

  @override
  String dayBarSemantics(String date, int done, int scheduled) {
    return '$date: $scheduledটির মধ্যে $doneটি সম্পন্ন';
  }

  @override
  String get notes => 'নোট';

  @override
  String get noNotesYet =>
      'এখনও কোনো নোট নেই। আজ স্ক্রিনে অভ্যাসে লং-প্রেস করে যোগ করুন।';

  @override
  String deleteHabitTitle(String name) {
    return '$name মুছবেন?';
  }

  @override
  String get deleteHabitBody =>
      'এতে অভ্যাস ও এর সব ইতিহাস মুছে যাবে। ইতিহাস রাখতে চাইলে আর্কাইভ করুন।';

  @override
  String get delete => 'মুছুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get nameRequired => 'অভ্যাসের একটি নাম দিন';

  @override
  String get pickAtLeastOneDay => 'অন্তত একটি দিন বেছে নিন';

  @override
  String get habitUpdated => 'পরিবর্তন সংরক্ষিত';

  @override
  String habitCreated(String name) {
    return '$name যোগ হয়েছে';
  }

  @override
  String get discardTitle => 'পরিবর্তন বাতিল করবেন?';

  @override
  String get discardBody => 'কিছু পরিবর্তন এখনও সংরক্ষণ হয়নি।';

  @override
  String get discard => 'বাতিল করুন';

  @override
  String get newHabit => 'নতুন অভ্যাস';

  @override
  String get habitName => 'অভ্যাসের নাম';

  @override
  String get habitNameHint => 'যেমন: পানি পান';

  @override
  String get iconAndColor => 'আইকন ও রং বেছে নিন';

  @override
  String get goalType => 'লক্ষ্যের ধরন';

  @override
  String get goalYesNo => 'হ্যাঁ / না';

  @override
  String get goalCount => 'সংখ্যা';

  @override
  String get goalTime => 'সময়';

  @override
  String get goalPerDay => 'দৈনিক লক্ষ্য';

  @override
  String get unit => 'একক';

  @override
  String get unitHint => 'যেমন: গ্লাস, পৃষ্ঠা';

  @override
  String get repeat => 'পুনরাবৃত্তি';

  @override
  String get repeatEveryDay => 'প্রতিদিন';

  @override
  String get repeatSpecificDays => 'কিছু দিন';

  @override
  String get repeatPerWeek => 'সাপ্তাহিক';

  @override
  String get timesPerWeekUnit => 'বার প্রতি সপ্তাহে';

  @override
  String get reminders => 'রিমাইন্ডার';

  @override
  String get removeReminder => 'রিমাইন্ডার সরান';

  @override
  String get addReminder => '+ রিমাইন্ডার যোগ করুন';

  @override
  String get remindersOff => 'এই অভ্যাসের রিমাইন্ডার বন্ধ।';

  @override
  String get moreOptions => 'আরও অপশন';

  @override
  String get startDate => 'শুরুর তারিখ';

  @override
  String get endDate => 'শেষের তারিখ';

  @override
  String get noEndDate => 'শেষ তারিখ নেই';

  @override
  String get clearEndDate => 'শেষ তারিখ মুছুন';

  @override
  String get note => 'নোট';

  @override
  String get habitNoteHint => 'এই অভ্যাস আপনার কাছে কেন গুরুত্বপূর্ণ';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ';

  @override
  String get saveHabit => 'অভ্যাস সংরক্ষণ';

  @override
  String get suggestWater => 'পানি পান';

  @override
  String get suggestRead => 'বই পড়া';

  @override
  String get suggestWalk => 'হাঁটা';

  @override
  String get suggestMeditate => 'ধ্যান';

  @override
  String get suggestSleep => '১১টার আগে ঘুম';

  @override
  String get suggestNoSugar => 'চিনি নয়';

  @override
  String get unitGlasses => 'গ্লাস';

  @override
  String get unitPages => 'পৃষ্ঠা';

  @override
  String colorNumber(int number) {
    return 'রং $number';
  }

  @override
  String iconNumber(int number) {
    return 'আইকন $number';
  }

  @override
  String get statsEmptyTitle => 'আপনার অগ্রগতি এখানে দেখাবে';

  @override
  String get statsEmptyNoHabits =>
      'একটি অভ্যাস যোগ করে কয়েকবার চেক-ইন করুন, তারপর সপ্তাহ ও মাসের হিসাব দেখুন।';

  @override
  String get statsEmptyPeriod =>
      'এই সময়ের জন্য এখনও কিছু নেই। চেক-ইন এখানে দেখাবে।';

  @override
  String get week => 'সপ্তাহ';

  @override
  String get month => 'মাস';

  @override
  String get jumpToToday => 'আজ';

  @override
  String get vsLastWeek => 'গত সপ্তাহের তুলনায়';

  @override
  String get vsLastMonth => 'গত মাসের তুলনায়';

  @override
  String get summary => 'সারসংক্ষেপ';

  @override
  String get habitsCompleted => 'সম্পন্ন অভ্যাস';

  @override
  String get currentStreak => 'চলতি স্ট্রিক';

  @override
  String daysCount(int count) {
    return '$count দিন';
  }

  @override
  String get perfectDays => 'নিখুঁত দিন';

  @override
  String get longestStreak => 'দীর্ঘতম স্ট্রিক';

  @override
  String get totalCheckIns => 'মোট চেক-ইন';

  @override
  String get byHabit => 'অভ্যাস অনুযায়ী';

  @override
  String insightBetterWeek(int percent) {
    return 'গত সপ্তাহের চেয়ে $percent% ভালো করেছেন।';
  }

  @override
  String insightBetterMonth(int percent) {
    return 'গত মাসের চেয়ে $percent% ভালো করেছেন।';
  }

  @override
  String insightHardestDay(String weekday) {
    return '$weekday আপনার সবচেয়ে কঠিন দিন।';
  }

  @override
  String get insightSteady => 'আগের মতোই স্থির। ধারাবাহিকতাই আসল অভ্যাস।';

  @override
  String get insightKeepGoing => 'প্রতিটি চেক-ইন গুরুত্বপূর্ণ। চালিয়ে যান।';

  @override
  String get allHabits => 'সব অভ্যাস';

  @override
  String get noData => 'তথ্য নেই';

  @override
  String get less => 'কম';

  @override
  String get more => 'বেশি';

  @override
  String get perfectDay => 'সব সম্পন্ন';

  @override
  String doneOfScheduled(int done, int scheduled) {
    return '$scheduledটির মধ্যে $doneটি সম্পন্ন';
  }

  @override
  String get trendSame => 'একই';

  @override
  String trendUp(int percent, String compared) {
    return '$compared $percent% বেশি';
  }

  @override
  String trendDown(int percent, String compared) {
    return '$compared $percent% কম';
  }

  @override
  String get yourWidgets => 'আপনার উইজেট';

  @override
  String get widgetsSubtitle => 'আপনার অভ্যাস, আপনার হোম স্ক্রিন।';

  @override
  String get livePreview => 'লাইভ প্রিভিউ';

  @override
  String get preview => 'প্রিভিউ';

  @override
  String get myWidgets => 'আমার উইজেট';

  @override
  String widgetsUsed(int used, int limit) {
    return '$limitটির মধ্যে $usedটি ব্যবহৃত';
  }

  @override
  String get chooseAWidget => 'উইজেট বেছে নিন';

  @override
  String get removeWidget => 'উইজেট সরান';

  @override
  String get removeWidgetTitle => 'এই উইজেট সরাবেন?';

  @override
  String get removeWidgetBody => 'আপনার অভ্যাস ও ইতিহাস নিরাপদ থাকবে।';

  @override
  String get remove => 'সরান';

  @override
  String get widgetLimitTitle => 'উইজেটের সীমা পূর্ণ';

  @override
  String widgetLimitBody(int limit) {
    return 'ফ্রি সংস্করণে সব অপশনসহ $limitটি উইজেট আছে। নতুন যোগ করতে একটি সরান, অথবা সীমাহীন উইজেটের জন্য Plus নিন।';
  }

  @override
  String get widgetSingleHabit => 'একক অভ্যাস';

  @override
  String get widgetSingleHabitDesc => 'বড় চেক বাটনসহ একটি অভ্যাস';

  @override
  String get widgetTodayList => 'আজকের তালিকা';

  @override
  String get widgetTodayListDesc => 'চেক বাটনসহ ৩ বা ৬টি পর্যন্ত অভ্যাস';

  @override
  String get widgetProgressRing => 'অগ্রগতি রিং';

  @override
  String get widgetProgressRingDesc => 'এক নজরে আজকের অগ্রগতি';

  @override
  String get widgetWeekStrip => 'সপ্তাহের স্ট্রিপ';

  @override
  String get widgetWeekStripDesc => 'সম্পন্ন চিহ্নসহ সাত দিন';

  @override
  String get widgetMonthHeatmap => 'মাসের হিটম্যাপ';

  @override
  String get widgetMonthHeatmapDesc => 'একটি বা সব অভ্যাসের ক্যালেন্ডার';

  @override
  String get widgetStreakCounter => 'স্ট্রিক কাউন্টার';

  @override
  String get widgetStreakCounterDesc => 'শিখাসহ চলতি স্ট্রিক';

  @override
  String get widgetBuilder => 'উইজেট বিল্ডার';

  @override
  String get widgetType => 'উইজেটের ধরন';

  @override
  String get widgetSizeLabel => 'আকার';

  @override
  String sizeMedium(String grid) {
    return 'মাঝারি $grid';
  }

  @override
  String sizeLarge(String grid) {
    return 'বড় $grid';
  }

  @override
  String get habitsShown => 'প্রদর্শিত অভ্যাস';

  @override
  String get widgetUsesAllHabits => 'এই উইজেট আজকের সব অভ্যাস ব্যবহার করে।';

  @override
  String widgetMaxHabits(int count) {
    return 'এই আকারে সর্বোচ্চ $countটি অভ্যাস দেখায়';
  }

  @override
  String get theme => 'থিম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get themeDevice => 'ডিভাইস';

  @override
  String get themeAccent => 'অ্যাকসেন্ট';

  @override
  String get background => 'পটভূমি';

  @override
  String get bgSolid => 'নিরেট';

  @override
  String get bgGradient => 'গ্রেডিয়েন্ট';

  @override
  String get bgTransparent => 'স্বচ্ছ';

  @override
  String get opacity => 'অস্বচ্ছতা';

  @override
  String get cornerRadius => 'কোণের বক্রতা';

  @override
  String get cornerSquare => 'চৌকো';

  @override
  String get cornerRounded => 'গোলাকার';

  @override
  String get cornerRound => 'পূর্ণ গোল';

  @override
  String get textSize => 'লেখার আকার';

  @override
  String get sizeS => 'ছোট';

  @override
  String get sizeM => 'মাঝারি';

  @override
  String get sizeL => 'বড়';

  @override
  String get showOnWidget => 'উইজেটে দেখান';

  @override
  String get showTitle => 'শিরোনাম';

  @override
  String get showStreak => 'স্ট্রিক';

  @override
  String get showDate => 'তারিখ';

  @override
  String get showPercentage => 'শতাংশ';

  @override
  String get tapAction => 'ট্যাপ করলে';

  @override
  String get tapCheck => 'চেক করুন';

  @override
  String get tapOpenToday => 'আজ খুলুন';

  @override
  String get tapOpenStats => 'পরিসংখ্যান খুলুন';

  @override
  String get weekStarts => 'সপ্তাহ শুরু';

  @override
  String get contrastWarning =>
      'কিছু ওয়ালপেপারে লেখা পড়তে কষ্ট হতে পারে। অস্বচ্ছতা বাড়ান বা অন্য থিম নিন।';

  @override
  String get addToHomeScreen => 'হোম স্ক্রিনে যোগ করুন';

  @override
  String get widgetSaved => 'উইজেট \"আমার উইজেট\"-এ সংরক্ষিত';

  @override
  String get widgetUpdated => 'উইজেট আপডেট হয়েছে';

  @override
  String get widgetPreviewSemantics => 'উইজেট প্রিভিউ';

  @override
  String get widgetPickHabit => 'একটি অভ্যাস বেছে নিন';

  @override
  String get widgetNothingToday => 'আজ কিছু নির্ধারিত নেই';

  @override
  String get today => 'আজ';

  @override
  String get thisWeek => 'এই সপ্তাহ';

  @override
  String get accountAndBackup => 'অ্যাকাউন্ট ও ব্যাকআপ';

  @override
  String get yourName => 'আপনার নাম';

  @override
  String get notSignedIn => 'সাইন ইন করা নেই';

  @override
  String get backUpNow => 'এখনই ব্যাকআপ';

  @override
  String get restore => 'ফিরিয়ে আনুন';

  @override
  String get exportData => 'ফাইল এক্সপোর্ট';

  @override
  String get exportFormats => 'CSV ও JSON';

  @override
  String get importData => 'ফাইল ইমপোর্ট';

  @override
  String get availableWithCloud => 'ক্লাউড ব্যাকআপ যুক্ত হলে এটি কাজ করবে।';

  @override
  String get defaultReminderTime => 'ডিফল্ট রিমাইন্ডারের সময়';

  @override
  String get quietHours => 'নীরব সময়';

  @override
  String get dailySummary => 'দৈনিক সারাংশ';

  @override
  String get dailySummaryHint => '\"আজ ৫টির মধ্যে ৩টি সম্পন্ন\"';

  @override
  String get weeklyReport => 'সাপ্তাহিক রিপোর্ট';

  @override
  String get weeklyReportHint => 'গত সপ্তাহের হার ও একটি পর্যবেক্ষণ';

  @override
  String get appearance => 'চেহারা';

  @override
  String get textNormal => 'সাধারণ';

  @override
  String get textLarge => 'বড়';

  @override
  String get textExtraLarge => 'অনেক বড়';

  @override
  String get preferences => 'পছন্দসমূহ';

  @override
  String get language => 'ভাষা';

  @override
  String get haptics => 'ভাইব্রেশন';

  @override
  String get animations => 'অ্যানিমেশন';

  @override
  String get celebrations => 'মাইলফলক উদযাপন';

  @override
  String get celebrationsHint => '৭, ৩০, ১০০ ও ৩৬৫ দিনে';

  @override
  String get habits => 'অভ্যাস';

  @override
  String get archivedHabits => 'আর্কাইভ করা অভ্যাস';

  @override
  String get noArchivedTitle => 'কিছু আর্কাইভ করা নেই';

  @override
  String get noArchivedBody =>
      'আর্কাইভ করা অভ্যাসের ইতিহাস থাকে, যেকোনো সময় ফিরিয়ে আনা যায়।';

  @override
  String get plusTitle => 'হ্যাবিটো Plus';

  @override
  String get plusBody =>
      'সীমাহীন উইজেট। এককালীন বা বার্ষিক। বিজ্ঞাপন কখনও নয়।';

  @override
  String get learnMore => 'আরও জানুন';

  @override
  String get privacy => 'গোপনীয়তা';

  @override
  String get whatWeStore => 'আমরা কী সংরক্ষণ করি';

  @override
  String get whatWeStoreBody =>
      'শুধু আপনার অ্যাকাউন্ট ইমেইল, অভ্যাস, চেক-ইন ও সেটিংস। কোনো বিজ্ঞাপন বা ট্র্যাকার নেই, কিছুই বিক্রি বা শেয়ার করা হয় না।';

  @override
  String get privacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signOutTitle => 'সাইন আউট করবেন?';

  @override
  String get signOutBody => 'আপনার অগ্রগতি এই ফোনে ও ব্যাকআপে থাকবে।';

  @override
  String get deleteAccount => 'আমার অ্যাকাউন্ট ও তথ্য মুছুন';

  @override
  String get deleteAccountTitle => 'অ্যাকাউন্ট ও তথ্য মুছবেন?';

  @override
  String get deleteAccountBody =>
      'এতে আপনার অভ্যাস, চেক-ইন, সেটিংস ও ব্যাকআপ এই ফোন ও ক্লাউড থেকে স্থায়ীভাবে মুছে যাবে।';

  @override
  String versionLabel(String version) {
    return 'হ্যাবিটো $version';
  }

  @override
  String get noAdsPromise => 'বিজ্ঞাপন নেই। ট্র্যাকার নেই। কখনও না।';

  @override
  String get signIn => 'Google দিয়ে সাইন ইন';

  @override
  String get signInHint => 'অগ্রগতি ব্যাকআপ রাখুন, যেকোনো ফোনে ফিরিয়ে আনুন';

  @override
  String get signedOutMessage => 'সাইন আউট হয়েছে। আপনার অগ্রগতি এই ফোনে আছে।';

  @override
  String get signedInMessage => 'সাইন ইন হয়েছে। ব্যাকআপ চালু।';
}
