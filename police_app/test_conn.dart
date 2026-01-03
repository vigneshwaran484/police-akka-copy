import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Testing Supabase Connection...');
  
  const url = 'https://comiypoedqvbwdpzgurt.supabase.co';
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvbWl5cG9lZHF2YndkcHpndXJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU4MTYyODYsImV4cCI6MjA1MTM5MjI4Nn0.sb_publishable_okkP394fKnv1m3Y5-Nl9nA_EKJncznK';
  
  try {
    await Supabase.initialize(url: url, anonKey: key);
    final client = Supabase.instance.client;
    
    // Try a simple read (even if empty or error, check if 401)
    final response = await client.from('citizens').select().limit(1);
    print('Success! Data: $response');
  } catch (e) {
    print('Error: $e');
  }
}
