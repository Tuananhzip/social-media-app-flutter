import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/components/button/button_login.dart';
import 'package:social_media_app/screens/components/dialog/dialog_register.dart';
import 'package:social_media_app/screens/components/field/field_login.dart';
import 'package:social_media_app/screens/components/form/general_form.dart';
import 'package:social_media_app/screens/register/register_verify.dart';
import 'package:social_media_app/serviecs/Authentication/auth_services.dart';
import 'package:social_media_app/serviecs/Users/user_services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/handle_icon_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthenticationServices authServices = AuthenticationServices();
  final UserServices userServices = UserServices();
  String? emailErrorText, passwordErrorText, confirmPasswordErrorText;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isRegisterSuccess = false;

  void validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailErrorText = 'Email is required';
      } else if (!isValidEmail(value)) {
        emailErrorText = 'Enter a valid email address (example@gmail.com)';
      } else {
        emailErrorText = null;
      }
    });
  }

  void validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordErrorText = 'Password is required';
      } else if (!isValidPassword(value)) {
        passwordErrorText =
            'Enter a valid password (least one upper case, least one lower case, least one digit,least one Special character, least 8 characters in length) example: Vignesh123!';
      } else {
        passwordErrorText = null;
      }
    });
  }

  void validatePasswordConfirm(String password, String confirmPassword) {
    setState(() {
      if (confirmPassword.isEmpty) {
        confirmPasswordErrorText = 'Confirm password is required';
      } else if (!comparePasswordConfirm(password, confirmPassword)) {
        confirmPasswordErrorText = 'Confirmation passwords are not the same';
      } else {
        confirmPasswordErrorText = null;
      }
    });
  }

  bool isValidPassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool comparePasswordConfirm(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return false;
    } else {
      return true;
    }
  }

  void navigationToLoginScreen() {
    Navigator.pushNamed(context, '/login');
  }

  void handleIcon(HandleIconField handle) {
    setState(() {
      switch (handle) {
        case HandleIconField.clear:
          emailController.text = '';
          return;
        case HandleIconField.visibilityPassword:
          obscurePassword = !obscurePassword;
          return;
        case HandleIconField.visibilityConfirmPassword:
          obscureConfirmPassword = !obscureConfirmPassword;
          return;
      }
    });
  }

  void onSubmit() async {
    setState(() {
      isLoading = true;
    });
    final resultEmail = emailController.text.trim();
    final resultPassword = passwordController.text.trim();
    final resultConfirmPassword = confirmPasswordController.text.trim();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshotEmailExist = await firestore
        .collection('users')
        .where('email', isEqualTo: resultEmail)
        .get();
    if (querySnapshotEmailExist.docs.isNotEmpty) {
      // xác định email tồn tại
      setState(() {
        emailErrorText = '$resultEmail is already registered.';
      });
      // ignore: avoid_print
      print(emailErrorText);
    }
    validateEmail(resultEmail);
    validatePassword(resultPassword);
    validatePasswordConfirm(resultPassword, resultConfirmPassword);
    bool isValidation = formKey.currentState!.validate();
    if (isValidation) {
      try {
        await authServices.createNewAccount(resultEmail, resultPassword);
        isRegisterSuccess =
            (FirebaseAuth.instance.currentUser != null) ? true : false;
      } on FirebaseAuthException catch (error) {
        // ignore: avoid_print
        print("ERROR send email verify !!! $error");
        emailErrorText = error.message;
      }
      if (isRegisterSuccess) {
        try {
          await userServices.addUserEmail(resultEmail);
        } catch (error) {
          // ignore: avoid_print
          print("userServices.addUserEmail (Register): ---> $error");
        }
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const RegisterVerifyScreen(),
        ));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeneralForm(listWidget: [
      const SizedBox(
        height: 45.0,
      ),
      DialogScreen(
        title: "Do you want to stop creating your account?",
        content: const Text(
            "If you stop now, you'll lose any progress you've made."),
        labelStatusStop: "Stop creating account",
        labelStatusContinue: "Continue creating account",
        onPressedStop: navigationToLoginScreen,
        onPressedContinue: () => {Navigator.pop(context)},
        typeDialogButtonBack: true,
      ),
      const SizedBox(
        height: 16.0,
      ),
      const Text(
        "What's your email?",
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24.0),
      ),
      const Text(
        "Enter the email where you can be contacted. No one will see this on your profile.",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
      ),
      const SizedBox(
        height: 16.0,
      ),
      Expanded(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Email Input
              InputFieldLogin(
                controller: emailController,
                text: 'Email',
                obscure: false,
                textInputType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: const Icon(Icons.close),
                isValidation: (value) => emailErrorText,
                onPressSuffixIcon: () => handleIcon(HandleIconField.clear),
              ),
              const SizedBox(
                height: 16.0,
              ),
              //Password Input
              InputFieldLogin(
                controller: passwordController,
                text: 'Password',
                obscure: obscurePassword,
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.password),
                suffixIcon: obscurePassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                isValidation: (value) => passwordErrorText,
                onPressSuffixIcon: () =>
                    handleIcon(HandleIconField.visibilityPassword),
              ),
              const SizedBox(
                height: 16.0,
              ),
              InputFieldLogin(
                controller: confirmPasswordController,
                text: 'Confirm password',
                obscure: obscureConfirmPassword,
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.password),
                suffixIcon: obscureConfirmPassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                isValidation: (value) => confirmPasswordErrorText,
                onPressSuffixIcon: () =>
                    handleIcon(HandleIconField.visibilityConfirmPassword),
              ),
              const SizedBox(
                height: 16.0,
              ),
              ButtonLogin(
                text: "Next",
                onTap: onSubmit,
              ),
              const SizedBox(
                height: 16.0,
              ),
              SizedBox(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ))
                    : null,
              )
            ],
          ),
        ),
      ),
      DialogScreen(
        title: "Already have an account?",
        labelStatusStop: "Login",
        labelStatusContinue: "Continue creating account",
        onPressedStop: navigationToLoginScreen,
        onPressedContinue: () => {Navigator.pop(context)},
        typeDialogButtonBack: false,
      ),
    ]);
  }
}
