import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: AppColors.backgroundColor,
    primary: AppColors.primaryColor,
    secondary: AppColors.greyColor,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.black,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.blackColor),
    titleMedium: TextStyle(color: AppColors.blackColor),
    labelMedium: TextStyle(color: AppColors.blackColor),
    bodyLarge: TextStyle(color: AppColors.blackColor),
    titleLarge: TextStyle(color: AppColors.blackColor),
    labelLarge: TextStyle(color: AppColors.blackColor),
    bodySmall: TextStyle(color: AppColors.blackColor),
    titleSmall: TextStyle(color: AppColors.blackColor),
    labelSmall: TextStyle(color: AppColors.blackColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.blueColor,
      foregroundColor: AppColors.backgroundColor,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.primaryColor,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Color(0xFF212121),
    primary: Color(0xFF424242),
    secondary: Color(0xFF616161),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.backgroundColor),
    titleMedium: TextStyle(color: AppColors.backgroundColor),
    labelMedium: TextStyle(color: AppColors.backgroundColor),
    bodyLarge: TextStyle(color: AppColors.backgroundColor),
    titleLarge: TextStyle(color: AppColors.backgroundColor),
    labelLarge: TextStyle(color: AppColors.backgroundColor),
    bodySmall: TextStyle(color: AppColors.backgroundColor),
    titleSmall: TextStyle(color: AppColors.backgroundColor),
    labelSmall: TextStyle(color: AppColors.backgroundColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.blueColor,
      foregroundColor: AppColors.backgroundColor,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: AppColors.secondaryColor,
  ),
);
