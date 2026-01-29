import 'package:flutter/material.dart';
import 'package:flutter_application_11/forget_pass_screen.dart';
import 'package:flutter_application_11/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child:Column(
                children: [
                  SizedBox(height: 40),
                  Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 200,
                fit: BoxFit.contain,
              ),
               Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'مرحبا بعودتك! الرجاء تسجيل الدخول للمتابعة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
                ],
              ) 
               
              
            ),
            const SizedBox(height: 20),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم أو البريد الالكتروني',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  obscureText: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.visibility_off,color: Colors.blue[700],),
                      onPressed: () {
                        
                        icon:
                        Icon(Icons.visibility);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                // Handle login action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 133, 241),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgetPassScreen()),
                );
                 
              },
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
              ),
            ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: Text(
                    'إنشاء حساب ',
                    style: TextStyle(fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                  },
                  child: Text(
                    'ليس لديك حساب؟',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}