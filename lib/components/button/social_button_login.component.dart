import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media_app/utils/app_colors.dart';

class SocialLoginButtonImageComponent extends StatelessWidget {
  const SocialLoginButtonImageComponent(
      {super.key, this.onTapFacebook, this.onTapGoogle});
  final void Function()? onTapFacebook;
  final void Function()? onTapGoogle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTapGoogle,
            child: Container(
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ]),
              child: Image.asset(
                "assets/images/google_icon.png",
                height: 25,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTapFacebook,
            child: Container(
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ]),
              child: Image.asset(
                "assets/images/facebook_icon.png",
                height: 25,
              ),
            ),
          ),
        )
      ],
    );
  }
}
