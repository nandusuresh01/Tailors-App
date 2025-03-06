import 'package:flutter/material.dart';
import 'package:tailor_app/main.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactcontroller = TextEditingController();
  final TextEditingController addresscontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmPasswordcontroller =
      TextEditingController();





  Future<void> register() async {
    try {
      await supabase.auth.signUp(
          password: passwordcontroller.text, email: emailController.text);
          print("Registration Success");
      insertData();
    } catch (e) {
      print(" Registration Error: $e");
    }
  }

  Future<void> insertData() async {
    try {
      await supabase.from('tbl_tailor').insert({
        'tailor_name': nameController.text,
        'tailor_email': emailController.text,
        'tailor_contact': contactcontroller.text,
        'tailor_address': addresscontroller.text,
        'tailor_password': passwordcontroller.text,
      });
    } catch (e) {
      print("Error storing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tailor Registration",
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                fontSize: 30, // Set the font size to make it large
              ),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: "Name", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: contactcontroller,
              decoration: InputDecoration(
                  labelText: "Contact", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: addresscontroller,
              decoration: InputDecoration(
                  labelText: "Address", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: passwordcontroller,
              decoration: InputDecoration(
                  labelText: "Password", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: confirmPasswordcontroller,
              decoration: InputDecoration(
                  labelText: "Confirm Password", border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                register();
              },
              child: Text("Register"),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                register();
              },
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}
