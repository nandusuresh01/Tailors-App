import 'package:flutter/material.dart';
import 'package:project/Home.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://rizfuhmgxjurqdpknpbe.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpemZ1aG1neGp1cnFkcGtucGJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwMzEwMTgsImV4cCI6MjA1NTYwNzAxOH0.Lf-hX6x-jP3JRL0S8X55u17C_usQPR-Svk4Wv9jNnVA',
  );
  runApp(MainApp());
}
        

// Get a reference your Supabase client
final supabase = Supabase.instance.client;


        

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Tail()
    );
  }
}
