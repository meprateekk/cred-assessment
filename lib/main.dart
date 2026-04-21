import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bill_cubit.dart';
import 'screens/home_screen.dart';
import 'services/bill_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key, BillRepository? repository})
    : repository = repository ?? BillRepository();

  final BillRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRED Assessment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5F2ED),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFCFAF7),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: BlocProvider(
        create: (_) => BillCubit(repository)..load(),
        child: const HomeScreen(),
      ),
    );
  }
}
