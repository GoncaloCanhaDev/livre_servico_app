import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _empNum = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _identifier.dispose();
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _empNum.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifier.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final empNum = _empNum.text.trim();
    if (password.length < 6) {
      setState(() {
        _error = 'Palavra-passe deve ter pelo menos 6 caracteres.';
        _info = null;
      });
      return;
    }
    if (_isSignUp) {
      if (email.isEmpty ||
          firstName.isEmpty ||
          lastName.isEmpty ||
          empNum.isEmpty) {
        setState(() {
          _error =
              'Email, nome e número de empregado obrigatórios para registar.';
          _info = null;
        });
        return;
      }
    } else if (identifier.isEmpty) {
      setState(() {
        _error = 'Indica o email ou número de empregado.';
        _info = null;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      if (_isSignUp) {
        await AuthService.instance.signUp(
          email,
          password,
          firstName: firstName,
          lastName: lastName,
          employeeNumber: empNum,
        );
        if (!mounted) return;
        setState(() {
          _info =
              'Conta criada. Verifica o teu email para confirmar a conta (se necessário) antes de entrar.';
        });
      } else {
        await AuthService.instance.signIn(identifier, password);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Erro: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline,
                    size: 56, color: AppColors.green),
                const SizedBox(height: 12),
                Text(
                  _isSignUp ? 'Criar conta' : 'Entrar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (_isSignUp) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstName,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Primeiro nome',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _lastName,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Último nome',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _empNum,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Nº empregado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else
                  TextField(
                    controller: _identifier,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email ou nº empregado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Palavra-passe',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13)),
                ],
                if (_info != null) ...[
                  const SizedBox(height: 12),
                  Text(_info!,
                      style: const TextStyle(
                          color: AppColors.greenDark, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSignUp ? 'Criar conta' : 'Entrar'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _isSignUp = !_isSignUp;
                            _error = null;
                            _info = null;
                          }),
                  child: Text(_isSignUp
                      ? 'Já tens conta? Entrar'
                      : 'Criar uma conta nova'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
