import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
	final String companyName;
	const LoginScreen({super.key, required this.companyName});

		@override
		Widget build(BuildContext context) {
					return Scaffold(
						appBar: AppBar(
							title: Text('Login - $companyName'),
						),
						body: Padding(
							padding: const EdgeInsets.all(24.0),
							child: Card(
								elevation: 6,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
								child: Padding(
									padding: const EdgeInsets.all(24.0),
									child: Column(
										mainAxisSize: MainAxisSize.min,
										children: [
											// Imagem/logo da empresa
											SizedBox(
												height: 100,
												child: Image.asset(
													'assets/images/company_logo_placeholder.png',
													fit: BoxFit.contain,
													errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 80, color: Colors.deepPurple),
												),
											),
											const SizedBox(height: 24),
											Text(
												'Bem-vindo à $companyName',
												style: Theme.of(context).textTheme.headlineSmall,
												textAlign: TextAlign.center,
											),
											const SizedBox(height: 32),
											TextField(
												decoration: const InputDecoration(
													labelText: 'Usuário',
													border: OutlineInputBorder(),
												),
											),
											const SizedBox(height: 16),
											TextField(
												obscureText: true,
												decoration: const InputDecoration(
													labelText: 'Senha',
													border: OutlineInputBorder(),
												),
											),
											const SizedBox(height: 32),
											SizedBox(
												width: double.infinity,
												child: ElevatedButton(
													onPressed: () {
														// ação de login
														ScaffoldMessenger.of(context).showSnackBar(
															const SnackBar(content: Text('Login realizado!')),
														);
														Navigator.pushNamed(context, '/home');
													},
													child: const Text('Entrar'),
												),
											),
											const SizedBox(height: 24),
											const Divider(),
											const SizedBox(height: 16),
											Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													const Text('Não é cadastrado? '),
													GestureDetector(
														onTap: () {
															Navigator.pushNamed(context, '/register');
														},
														child: Text(
															'Registre-se agora',
															style: TextStyle(
																color: Colors.deepPurple,
																fontWeight: FontWeight.bold,
																decoration: TextDecoration.underline,
															),
														),
													),
												],
											),
										],
									),
								),
							),
						),
					);
		}
}
