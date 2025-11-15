import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
	const RegisterScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Cadastro de Usuário'),
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
								Text(
									'Preencha seus dados para se cadastrar',
									style: Theme.of(context).textTheme.titleMedium,
									textAlign: TextAlign.center,
								),
								const SizedBox(height: 24),
								TextField(
									decoration: const InputDecoration(
										labelText: 'Nome completo',
										border: OutlineInputBorder(),
									),
								),
								const SizedBox(height: 16),
								TextField(
									decoration: const InputDecoration(
										labelText: 'E-mail',
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
											// ação de cadastro
											ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(content: Text('Cadastro realizado com sucesso!')),
											);
											Navigator.pop(context);
										},
										child: const Text('Cadastrar'),
									),
								),
							],
						),
					),
				),
			),
		);
	}
}
