import 'package:flutter/material.dart';

void displayMySnackBar(
  BuildContext context,
  String title,
) {
  final isDarkMode =
      MediaQuery.of(context).platformBrightness == Brightness.dark;
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor:
          isDarkMode ? Theme.of(context).colorScheme.secondary : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      content: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    ),
  );
}
