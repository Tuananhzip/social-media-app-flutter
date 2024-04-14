import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';

class RadioButtonWidget extends StatelessWidget {
  const RadioButtonWidget(
      {super.key, this.onChanged, required this.groupValue});
  final Genders? groupValue;
  final void Function(Genders?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Male'),
          leading: Radio<Genders>(
            activeColor: AppColors.blueColor,
            value: Genders.male,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Female'),
          leading: Radio<Genders>(
            activeColor: AppColors.blueColor,
            value: Genders.female,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
