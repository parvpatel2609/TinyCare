import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/components/my_textfield.dart';
import 'package:flutter_application_1/models/UserModel.dart';
import 'package:flutter_application_1/pages/login_page.dart';
// import 'package:flutter_application_1/services/Database.dart';
import 'package:flutter_application_1/services/encryptData.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ignore: non_constant_identifier_names
  final pass_helper = EncryptionHelper();

  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final partneremailcontroller = TextEditingController();
  final partnernamecontroller = TextEditingController();
  final securitycontroller = TextEditingController();
  final nameController = TextEditingController();

  //navigate to login page method
  void navigateToLoginPage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void checkValues() {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = confirmPasswordController.text.trim();
    String part_email = partneremailcontroller.text.trim();
    String part_name = partnernamecontroller.text.trim();
    String security = securitycontroller.text.trim();

    if (email == "" || name == "" || password == "" || cpassword == "" || part_email == "" || part_name == "" || security == "") {
      showErrorMessage("Please fill all the fiedls perfectly");
    } else if (password != cpassword) {
      showErrorMessage("Password do not match");
    } else {
      // print("hello");
      signUp(email, name, password, part_email, part_name, security);
    }
  }

  void signUp(String email,String name, String password, String part_email, String part_name, String security) async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    UserCredential? credential;

    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex) {
      print(ex.code.toString());
    }
    print("Credential : ");
    print(credential);
    if(credential != null){
      String uid = credential.user!.uid;
      UserModel new_user = UserModel(
        uid: uid,
        email: email,
        name: name,
        part_email: part_email,
        part_name: part_name,
        security: security
      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set(new_user.toMap()).then((value){
        print("New user is created");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      });
    }
  }

  //sing user in method
  // void signUserUp() async {
  //   //show loading circle
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return const Center(
  //         child: CircularProgressIndicator(),
  //       );
  //     },
  //   );

  //   //try to create user in
  //   try {
  //     if (passwordController.text == confirmPasswordController.text) {
  //       String passEncry = pass_helper.encryptData(passwordController.text);
  //       String Id = randomAlphaNumeric(15);
  //       Map<String, dynamic> userInfoMap = {
  //         "email": emailController.text,
  //         "password": passEncry,
  //         "part_email": partneremailcontroller.text,
  //         "part_name": partnernamecontroller.text,
  //         "Id": Id
  //       };

  //       await DatabaseMethods().addUserDetails(userInfoMap, Id).then((value) {
  //         Fluttertoast.showToast(
  //             msg: "User created successfully!",
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.CENTER,
  //             timeInSecForIosWeb: 1,
  //             backgroundColor: Colors.deepPurple,
  //             textColor: Colors.black,
  //             fontSize: 16.0);
  //       });

  //       Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => LoginPage()));
  //     } else {
  //       showErrorMessage("Password don't matched!");
  //     }

  //     // ignore: use_build_context_synchronously
  //     Navigator.pop(context);
  //   } on FirebaseAuthException catch (e) {
  //     // ignore: use_build_context_synchronously
  //     Navigator.pop(context);

  //     //show error message
  //     showErrorMessage(e.code);
  //   }
  // }

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

                //Partner name
                MyTextfield(
                  controller: partnernamecontroller,
                  hintText: "Husband/wife name",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //Partner email id textfield
                MyTextfield(
                  controller: partneremailcontroller,
                  hintText: "Husbnad/Wife Email id",
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

                //confirm password
                //password textfield
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //security question
                MyTextfield(
                  controller: securitycontroller,
                  hintText: "What is your child name?(Security Question)",
                  obscureText: false,
                ),


                const SizedBox(height: 25),

                //sign in button
                MyButton(
                  onTap: checkValues,
                  text: 'Sign Up',
                ),

                const SizedBox(height: 30),

                //not a member? register now
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => {navigateToLoginPage(context)},
                    child: const Text(
                      "Login Now",
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
