import 'package:flutter/material.dart';
import 'package:teste/src/auth/components/custom_text_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Column(
        children: [
          Expanded(child: Container(color: Colors.red)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email
                  const CustomTextField(icon: Icons.email, label: 'Email'),

                  // Senha
                  CustomTextField(
                    icon: Icons.lock,
                    label: 'Senha',
                    isSecret: true,
                  ),
            
                  //Botao de entrar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                 
                 //Esqueceu a senha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Esqueceu a senha?',
                      style: TextStyle(
                        color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                 


                //Divisor 
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                            color: Colors.grey.withAlpha(90),
                            thickness: 2,
                              ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child:  Text("Ou"),
                    ), 
                     Expanded(
                      child: Divider(
                            color: Colors.grey.withAlpha(90),
                            thickness: 2,
                              ),
                    ),
                ],
                
                ),
               ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
