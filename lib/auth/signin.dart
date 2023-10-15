import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pim/auth/signup.dart';
import 'package:pim/color.dart';
import 'package:pim/firebase_auth/firebase_service.dart';
import 'package:pim/home_page.dart';
import 'package:pim/utils/text_field_widget.dart';
import 'package:pim/utils/helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSaving = false;
  bool inviteActive = false;
  bool authorizeActive = false;
  bool get isSaving => _isSaving;
   LoadingIndicator loadingIndicator = LoadingIndicator();
  set isSaving(bool status) {
    setState(() {
      _isSaving = status;
    });
  }

  bool isFormValid() {
    if (_formKey.currentState!.validate() ) {
      return true;
    } else {
      return false;
    }
  }

  saveService1() async {
    try {
      if (!isFormValid()) {
        Flushbar(
          backgroundColor: Colors.redAccent,
          title: "Invalid input",
          message: "All Fields are mandatory",
          borderRadius: const BorderRadius.only(topRight: Radius.circular(8),topLeft: Radius.circular(8)),
          duration: const Duration(seconds: 2),
        ).show(context);
        return;
      }else{
        _signIn();
      }
      isSaving = true;
    } catch (e) {
      loadingIndicator.hideLoadingIndicator();
      if (kDebugMode) {
        print(e);
      }
     await Flushbar(
        title: "Error",
        message: "Some Error occurred. Try again later.",
        duration: const Duration(seconds: 2),
      ).show(context);
    } finally {
      isSaving = false;
    }
  }
  final AuthFunctions _signupFunctions = AuthFunctions();

  Future<void> _signIn() async {
    try {
      loadingIndicator.showLoadingIndicator(context);
      String? uid = await _signupFunctions.signIn(
        _emailController.text,
        _passwordController.text,
      );
      loadingIndicator.hideLoadingIndicator();
      if (uid != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(userId: uid,),
          ),
        );
      }
      loadingIndicator.hideLoadingIndicator();
    } catch (e) {
      await Flushbar(
        backgroundColor: Colors.redAccent,
        title: "Failed !",
        titleSize: 20,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(8),topLeft: Radius.circular(8)),
        message: '$e',
        duration: const Duration(seconds: 2),
      ).show(context);
      loadingIndicator.hideLoadingIndicator();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15,left: 20,bottom: 60),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Sign In',style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: c3
                  ),),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Text('Please sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white
                ),),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFieldWidget(
                          textInputType: TextInputType.emailAddress,
                          contentPadding: const EdgeInsets.all(14),
                          focusedBorderColor: c3,
                          borderColor: c3.withOpacity(0.5),
                          borderWidth: 2,
                          borderRadius: 8,
                          fillColor: Colors.white,
                          controller: _emailController,
                          hint: 'Email',
                          hintColor: c1.withOpacity(0.8),
                          validation: Validator.requiredValidation,

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFieldWidget(
                          suffixIcon: InkWell(
                              onTap: (){
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                          child:isPasswordVisible? Icon(CupertinoIcons.eye_slash, color: c3.withOpacity(0.5),):Icon(CupertinoIcons.eye, color: c3,)),
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 40,
                            minWidth: 40
                          ),
                          contentPadding: const EdgeInsets.all(14),
                          focusedBorderColor: c3,
                          borderColor: c3.withOpacity(0.5),
                          borderWidth: 2,
                          textInputType: TextInputType.visiblePassword,
                          borderRadius: 8,
                          fillColor: Colors.white,
                          controller: _passwordController,
                          hint: 'Password',
                          hintColor: c1.withOpacity(0.8),
                          obscureText: isPasswordVisible,
                          validation: Validator.requiredValidation,
                        ),
                      ),
                       GestureDetector(
                        onTap: () {
                          saveService1();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80,vertical: 30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(06),
                              color: c2 ,
                            ),
                            // width: 200,
                            alignment: Alignment.center,
                            child: isSaving
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                                : const Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),

                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Don\'t have an account ?  ' ,style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16
                          ),),
                          InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpPage()));
                              },
                              child: Text('Sign Up',style: TextStyle(
                                  color: c3,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16
                              ))),
                        ],

                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
