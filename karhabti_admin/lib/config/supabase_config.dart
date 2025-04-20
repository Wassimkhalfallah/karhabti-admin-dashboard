import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://meciuohrlynvdcibgnsf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lY2l1b2hybHludmRjaWJnbnNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg4NjU5NTcsImV4cCI6MjA1NDQ0MTk1N30.1TrPmXNZgs9Ql6MidvQgAU2HT0Ln1cixK15GHT96Gls';

  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
