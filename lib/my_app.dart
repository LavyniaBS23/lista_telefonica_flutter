import 'package:flutter/material.dart';
import 'package:lista_telefonica/pages/home_page.dart';
import 'package:lista_telefonica/cor.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Cor.createMaterialColor(const Color(0xFFFFFFFF)),
          //textTheme: GoogleFonts.robotoTextTheme()
        ),
      home: const HomePage(),
    );
  }

}
