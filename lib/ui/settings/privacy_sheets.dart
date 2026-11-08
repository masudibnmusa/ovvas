import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_scope.dart';

/// Email shown in the privacy policy's contact section. The section is hidden
/// while this is empty.
const kSupportEmail = '';

/// When the privacy policy text last changed.
final kPrivacyUpdated = DateTime(2026, 11, 8);

typedef _Section = ({IconData? icon, String title, String body});

/// "What we store": a short, plain summary of what the app keeps and where.
Future<void> showWhatWeStore(BuildContext context) {
  final l = context.l10n;
  return _showSheet(
    context,
    title: l.whatWeStore,
    intro: l.whatWeStoreIntro,
    sections: [
      (icon: Icons.smartphone_rounded, title: l.storeOnPhoneTitle, body: l.storeOnPhoneBody),
      (icon: Icons.cloud_outlined, title: l.storeCloudTitle, body: l.storeCloudBody),
      (icon: Icons.account_circle_outlined, title: l.storeAccountTitle, body: l.storeAccountBody),
      (icon: Icons.block_rounded, title: l.storeNeverTitle, body: l.storeNeverBody),
      (icon: Icons.picture_as_pdf_outlined, title: l.storeExportTitle, body: l.storeExportBody),
    ],
    footer: (sheetContext) => TextButton.icon(
      icon: const Icon(Icons.policy_outlined),
      label: Text(l.readFullPolicy),
      onPressed: () {
        Navigator.pop(sheetContext);
        showPrivacyPolicy(context);
      },
    ),
  );
}

/// The full privacy policy.
Future<void> showPrivacyPolicy(BuildContext context) {
  final l = context.l10n;
  final date = DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag()).format(kPrivacyUpdated);
  return _showSheet(
    context,
    title: l.privacyPolicy,
    subtitle: l.privacyUpdated(date),
    intro: l.privacyIntro,
    sections: [
      (icon: null, title: l.policyCollectTitle, body: l.policyCollectBody),
      (icon: null, title: l.policyUseTitle, body: l.policyUseBody),
      (icon: null, title: l.policyStorageTitle, body: l.policyStorageBody),
      (icon: null, title: l.policySharingTitle, body: l.policySharingBody),
      (icon: null, title: l.policyRetentionTitle, body: l.policyRetentionBody),
      (icon: null, title: l.policyChoicesTitle, body: l.policyChoicesBody),
      (icon: null, title: l.policyChildrenTitle, body: l.policyChildrenBody),
      (icon: null, title: l.policyChangesTitle, body: l.policyChangesBody),
      if (kSupportEmail.isNotEmpty)
        (icon: null, title: l.policyContactTitle, body: l.policyContactBody(kSupportEmail)),
    ],
  );
}

Future<void> _showSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String intro,
  required List<_Section> sections,
  Widget Function(BuildContext sheetContext)? footer,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      final c = ctx.colors;
      final text = Theme.of(ctx).textTheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 1,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            Semantics(header: true, child: Text(title, style: text.headlineSmall)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: text.bodySmall?.copyWith(color: c.textSecondary)),
            ],
            const SizedBox(height: 12),
            Text(intro, style: text.bodyLarge?.copyWith(color: c.textSecondary)),
            for (final s in sections) ...[
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.icon != null) ...[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: c.mint,
                      child: Icon(s.icon, size: 20, color: c.onMint),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(s.title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 6),
                        Text(s.body, style: text.bodyMedium?.copyWith(height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 24),
              Align(alignment: AlignmentDirectional.centerStart, child: footer(ctx)),
            ],
          ],
        ),
      );
    },
  );
}
