import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CustomColors {
  static Color customSwatchColor = Colors.green;
}

class SignUpScreen extends StatefulWidget {

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cpfController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  // Variável de estado para controlar se o cadastro atual é de um admin.
  bool _isCreatingAdmin = false;

  static final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static final phoneFormatter = MaskTextInputFormatter(
    mask: '## # ####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    super.dispose();
  }

  // Função que exibe o diálogo para inserir a senha de administrador.
  void _showAdminPasswordDialog() {
    final passwordDialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Acesso de Administrador'),
          content: TextField(
            controller: passwordDialogController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Digite a senha mestre"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              onPressed: () {
                // AVISO: A senha no código é INSEGURA para produção.
                // Considere buscar essa senha de uma fonte segura ou usar Cloud Functions.
                if (passwordDialogController.text == 'admin123') {
                  setState(() {
                    // Se a senha estiver correta, ativa o modo de criação de admin.
                    _isCreatingAdmin = true;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permissão de admin concedida para este cadastro.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Senha incorreta!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Função de cadastro de usuário.
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Salva os dados no Firestore, usando a variável de estado _isCreatingAdmin.
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'cpf': cpfController.text.trim(),
          'isAdmin': _isCreatingAdmin,
          'createdAt': Timestamp.now(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Já existe uma conta para este e-mail.';
      } else {
        message = 'Ocorreu um erro. Tente novamente.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro inesperado: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CustomColors.customSwatchColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Cadastro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 40,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(45),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: emailController,
                            icon: Icons.email,
                            label: 'Email',
                            validator: (email) {
                              if (email == null || email.isEmpty) return 'Por favor, digite seu e-mail.';
                              if (!email.contains('@')) return 'Por favor, digite um e-mail válido.';
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: passwordController,
                            icon: Icons.lock,
                            label: 'Senha',
                            isSecret: true,
                            validator: (password) {
                              if (password == null || password.isEmpty) return 'Por favor, digite sua senha.';
                              if (password.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: nameController,
                            icon: Icons.person,
                            label: 'Nome',
                            validator: (name) {
                              if (name == null || name.isEmpty) return 'Por favor, digite seu nome.';
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: phoneController,
                            icon: Icons.phone,
                            label: 'Celular',
                            inputFormatters: [phoneFormatter],
                            validator: (phone) {
                              if (phone == null || phone.isEmpty) return 'Por favor, digite seu celular.';
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: cpfController,
                            icon: Icons.file_copy,
                            label: 'CPF',
                            inputFormatters: [cpfFormatter],
                            validator: (cpf) {
                              if (cpf == null || cpf.isEmpty) return 'Por favor, digite seu CPF.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: _isLoading ? null : _signUp,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text(
                                      'Cadastrar usuário',
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // BOTÃO DE ADMIN MODIFICADO
                          SizedBox(
                            height: 45,
                            child: OutlinedButton.icon(
                              icon: Icon(
                                _isCreatingAdmin ? Icons.check_circle : Icons.security,
                              ),
                              label: Text(
                                _isCreatingAdmin ? 'Cadastrando como Admin' : 'Tornar Admin',
                                style: const TextStyle(fontSize: 18),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isCreatingAdmin ? Colors.green : Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                side: BorderSide(
                                  width: 2,
                                  color: _isCreatingAdmin ? Colors.green : Colors.grey,
                                ),
                              ),
                              onPressed: () {
                                if (_isCreatingAdmin) {
                                  // Permite desativar o modo admin se clicar novamente
                                  setState(() {
                                    _isCreatingAdmin = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Permissão de admin removida.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  // Se não for admin, mostra o diálogo para pedir a senha
                                  _showAdminPasswordDialog();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                left: 10,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
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


class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSecret;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.icon,
    required this.label,
    this.isSecret = false,
    this.inputFormatters,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        obscureText: isSecret,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}