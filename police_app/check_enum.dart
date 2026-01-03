import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  print('OAuthProvider values:');
  for (var v in OAuthProvider.values) {
    print(v.toString());
  }
}
