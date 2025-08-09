import 'package:animate_do/animate_do.dart';
import 'package:emo_music_app/controller/mood_history_provider.dart';
import 'package:emo_music_app/services/auth_exception.dart';
import 'package:emo_music_app/services/firebase_auth_service.dart';
import 'package:emo_music_app/ui/screens/auth/sign_up_screen.dart';
import 'package:emo_music_app/ui/screens/main_bottom_nav_bar_screen.dart';
import 'package:emo_music_app/ui/widgets/custom_auth_button.dart';
import 'package:emo_music_app/ui/widgets/custom_text_field.dart';
import 'package:emo_music_app/ui/widgets/snack_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSignUpTap;

  const LoginScreen({super.key, this.onSignUpTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final _firebaseAuthService = FirebaseAuthService();

  Future<void> _signInUser() async {
    try {
      final user = await _firebaseAuthService.signInWithEmailAndPassword(
        _emailTEController.text.trim(),
        _passwordTEController.text.trim(),
      );
      print(user);
      User? userFirebase = FirebaseAuthService().currentUser;
      if (userFirebase != null) {
        Provider.of<MoodHistoryProvider>(
          context,
          listen: false,
        ).setUserId(userFirebase.uid);
      }
      if (mounted) {
        SnackMessage.showSnakMessage(context, "Sign in success");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainBottomNavBarScreen(),
          ),
        );
      }
    } on AuthException catch (e) {
      print("Sign in error: ${e.message}");

      if (mounted) {
        SnackMessage.showSnakMessage(context, "Sign in failed: ${e.message} ");
      }
    } catch (e) {
      print(e.toString());
      if (!mounted) {
        return;
      }
      SnackMessage.showSnakMessage(
        context,
        "Something happen: ${e.toString()} ",
      );
    }
  }

  // Future<void> _signInWithGoogle() async {
  // try {
  // await _firebaseAuthService.signInWithGoogle();

  //   if (mounted) {
  //     SnackMessage.showSnakMessage(context, "Sign in success");

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const MainBottomNavBarScreen(),
  //       ),
  //     );
  //   }
  // } on AuthException catch (e) {
  //   if (mounted) {
  //     SnackMessage.showSnakMessage(
  //       context,
  //       "Google Sign in failed: ${e.message} ",
  //     );
  //   }
  // } catch (e) {
  //   print("Sign in aborted: $e");
  // }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                _buildLoginHeaderSection(),
                SizedBox(height: 40),
                FadeInUp(
                  duration: Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      CustomTextField(
                        textEditingController: _emailTEController,
                        icon: CupertinoIcons.mail,
                        hintText: "Email",
                        isPassword: false,
                        gradientColor: [Color(0xFF4A154B), Color(0xFF6B1A6B)],
                      ),
                      SizedBox(height: 20),

                      CustomTextField(
                        textEditingController: _passwordTEController,
                        icon: CupertinoIcons.lock,
                        hintText: "Password",

                        isPassword: true,
                        gradientColor: [Color(0xFF4A154B), Color(0xFF6B1A6B)],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14),

                FadeInUp(
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 400),
                  child: CustomAuthButton(
                    onPressed: () {
                      if (_emailTEController.text.isEmpty &&
                          _passwordTEController.text.isEmpty) {
                        SnackMessage.showSnakMessage(
                          context,
                          "Field Must not be empty",
                        );
                        return;
                      }

                      _signInUser();
                    },
                    text: "Log In",
                  ),
                ),
                SizedBox(height: 24),
                FadeIn(
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 400),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",

                        style: TextStyle(color: Color(0xFF1D1C1D)),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(
                                onLoginTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },

                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF4A154B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                _buildLoginBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHeaderSection() {
    return FadeInDown(
      duration: Duration(microseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFF4A154B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Welcome Back',

              style: TextStyle(
                color: Color(0xFF4A1548),

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Log in to your\naccount',

            style: TextStyle(
              color: Color(0xFF1D1C1D),
              height: 1.2,
              fontSize: 36,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBottomSection() {
    return FadeInUp(
      duration: Duration(milliseconds: 600),
      delay: Duration(milliseconds: 800),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFFE8E0E0)],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),

                // child: Text(
                //   "Or continue with",
                //   style: TextStyle(
                //     color: Color(0xFF1D1C1D),

                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ),

              Expanded(
                child: Container(
                  height: 1,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFFE8E0E0)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElasticIn(
          //       duration: Duration(milliseconds: 800),
          //       delay: Duration(milliseconds: 1000),
          //       child: _buildSocialButton(
          //         icon: Icons.g_mobiledata,
          //         label: "Google",
          //         gradientColors: [Color(0xFFDB4437), Color(0xFFF66D5B)],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // Widget _buildSocialButton({
  //   required IconData icon,
  //   required String label,
  //   required List<Color> gradientColors,
  // }) {
  //   return InkWell(
  //     onTap: () {
  //       _signInWithGoogle();
  //     },
  //     child: Container(
  //       height: 55,
  //       width: 150,

  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             gradientColors[0].withValues(alpha: 0.1),
  //             gradientColors[1].withValues(alpha: 0.1),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),

  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: gradientColors[0]),

  //           SizedBox(width: 8),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: gradientColors[0],

  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}
