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
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
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
								},
								child: const Text('Entrar'),
							),
						),
					],
				),
			),
		);
	}
}
