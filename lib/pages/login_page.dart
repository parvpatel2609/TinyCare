import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/components/my_textfield.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/register_page.dart';
import 'package:flutter_application_1/services/TokenService.dart';
import 'package:flutter_application_1/services/encryptData.dart';
import 'package:flutter_application_1/services/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final pass_helper = EncryptionHelper();
  final shered = SharedpreferenceHelper();
  static const secret = 'FJSKMSSJKMDJDHK54564643151';

  //navigate to register page
  void navigateToRegisterPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  //sing user in method
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try to sign in
    try {
      // print("Email id second: " + emailController.text);
      QuerySnapshot querysnapshot = await FirebaseFirestore.instance
          .collection("User")
          .where('email', isEqualTo: emailController.text)
          .get();

      if (querysnapshot.docs.isNotEmpty) {
        DocumentSnapshot uInformation = querysnapshot.docs.first;
        Map<String, dynamic> userData =
            uInformation.data() as Map<String, dynamic>;

        // ignore: avoid_print
        print("User details: $userData");
        // String d_pass = userData['password'].toString();
        // print("User Password: $d_pass");

        String decrypPass =
            pass_helper.decryptData(userData['password'].toString());

        if (decrypPass == passwordController.text) {
          //generate token for authentication
          // ignore: unused_local_variable
          final token = JWTService().generateTokenId(
              userData['Id'].toString(), userData['email'].toString(), secret);
          print("Generated Token: $token");

          bool fl_id = await shered.saveUserId(userData['Id'].toString());
          bool fl_email =
              await shered.saveUserEmail(userData['email'].toString());
          bool fl_token = await shered.saveUserToken(token);
          print("Token saved: $fl_token");

          // print("Flag _ id : $fl_id");
          // print("Flag _ Email : $fl_email");
          // print("Flag _ Token : $fl_token");

          print("Token is expied or not: ");
          print(JWTService().isTokenExpired(token));

          // final decodePayload = JWTService().verifyToken(token, secret);
          // print("Decoded token: $decodePayload");

          // Close the loading dialog
          if (context.mounted) Navigator.pop(context);

          // Check if the token is expired
          if (JWTService().isTokenExpired(token)) {
            Fluttertoast.showToast(
                msg: "Token expired! Please sign in again.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.deepPurple,
                textColor: Colors.black,
                fontSize: 16.0);
            shered.saveUserEmail("USEREMAILKEY");
            shered.saveUserId("USERIDKEY");
            shered.saveUserToken("USERTOKENKEY");
          } else {
            // Navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          // Close the loading dialog
          if (context.mounted) Navigator.pop(context);

          // Show error message for incorrect password
          Fluttertoast.showToast(
              msg: "Incorrect password!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.deepPurple,
              textColor: Colors.black,
              fontSize: 16.0);
        }
      } else {
        // Close the loading dialog
        if (context.mounted) Navigator.pop(context);

        Fluttertoast.showToast(
            msg: "User not found!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepPurple,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      //show error message
      showErrorMessage(e.code);
    }
  }

  //method to say about alert like email is wrong
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  void Register_Page () {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                //logo
                const Icon(Icons.lock, size: 100, color: Colors.deepPurple),

                const SizedBox(height: 50),

                //welcome back
                const Text("Welcome back, you've been missed!",
                    style: TextStyle(color: Colors.black, fontSize: 16)),

                const SizedBox(height: 25),

                //username textfield
                MyTextfield(
                  controller: emailController,
                  hintText: "Email id",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //forgot password
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'forgot password',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //sign in button
                MyButton(
                  onTap: signUserIn,
                  text: "Sing In",
                ),

                const SizedBox(height: 50),

                //not a member? register now
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Not a member?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => {navigateToRegisterPage(context)},
                    child: const Text(
                      "Register Now",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
