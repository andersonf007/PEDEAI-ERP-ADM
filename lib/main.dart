// main.dart

import 'package:flutter/material.dart';
import 'package:pedeaierpadm/Commom/supabaseConf.dart';
import 'package:pedeaierpadm/app_widget.dart';
import 'package:pedeaierpadm/view/login/login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(Provider(create: (context) => LoginPage(), child: AppWidget()));
}
