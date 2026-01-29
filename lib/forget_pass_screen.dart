import 'package:flutter/material.dart';

class ForgetPassScreen extends StatelessWidget {
  const ForgetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text('استعادة كلمة المرور'),
        centerTitle: true,
        
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              height: 400,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                 Icon(Icons.lock_reset,color: Colors.blue[700],size: 100),
                  SizedBox(height: 20),
                  Text(
                    'استعادة كلمة المرور',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.phone,color: Colors.blue[700],),
                            onPressed: () {},
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
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
                      'إرسال رمز التحقق',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                 ),
                  // Add more UI elements as needed
                ],
              ),
            ),
          ),
        ),
    );
  }
}