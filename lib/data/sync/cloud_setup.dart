import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';
import 'cloud_sync.dart';
import 'supabase_sync.dart';

// Pass these when building or running, e.g.
//   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
//               --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
// Without them the app keeps data on the phone only.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// The deep link the sign-in page returns to. Registered in
/// AndroidManifest.xml, ios/Runner/Info.plist and the Supabase dashboard.
const authRedirectUrl = 'ovvas://login-callback';

Future<CloudSync> createCloudSync(AppDatabase db) async {
  if (_supabaseUrl.isEmpty || _supabaseKey.isEmpty) return LocalOnlyCloudSync();
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseKey);
  final sync = SupabaseCloudSync(db, redirectUrl: authRedirectUrl);
  await sync.init();
  return sync;
}
