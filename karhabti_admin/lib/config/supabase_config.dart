import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ixlkwjxvbbprbgqcghjx.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_C_GUwW7ev6l_D6bMhnOoUQ_mc7IYc7C';

  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
