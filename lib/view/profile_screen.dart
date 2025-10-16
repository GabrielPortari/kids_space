import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
	const ProfileScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Perfil'),
			),
			body: Padding(
				padding: const EdgeInsets.all(24.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						const SizedBox(height: 24),
									Stack(
										alignment: Alignment.center,
										children: [
											CircleAvatar(
												radius: 50,
												backgroundColor: Colors.deepPurple[100],
												child: const Icon(Icons.person, size: 60, color: Colors.deepPurple),
											),
											Positioned(
												bottom: 0,
												right: 0,
												child: Material(
													color: Colors.transparent,
													child: InkWell(
														borderRadius: BorderRadius.circular(20),
														onTap: () {
															// TODO: Implementar ação para adicionar foto
														},
														child: Container(
															decoration: BoxDecoration(
																color: Colors.deepPurple,
																shape: BoxShape.circle,
															),
															padding: const EdgeInsets.all(6),
															child: const Icon(Icons.add_a_photo, color: Colors.white, size: 20),
														),
													),
												),
											),
										],
									),
						const SizedBox(height: 24),
						const Text(
							'João Oliveira',
							style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
						),
						const SizedBox(height: 8),
						const Text(
							'Colaborador',
							style: TextStyle(fontSize: 18, color: Colors.deepPurple),
						),
						const SizedBox(height: 24),
						Card(
							elevation: 2,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
							child: Padding(
								padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
														children: const [
															Row(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	Text('Nome:', style: TextStyle(fontSize: 16)),
																	SizedBox(width: 8),
																	Text('João Oliveira', style: TextStyle(fontSize: 16)),
																],
															),
															Divider(),
															Row(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	Text('Email:', style: TextStyle(fontSize: 16)),
																	SizedBox(width: 8),
																	Text('joao.oliveira@email.com', style: TextStyle(fontSize: 16)),
																],
															),
															Divider(),
															Row(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	Text('Telefone:', style: TextStyle(fontSize: 16)),
																	SizedBox(width: 8),
																	Text('(11) 91234-5678', style: TextStyle(fontSize: 16)),
																],
															),
															Divider(),
															Row(
																mainAxisAlignment: MainAxisAlignment.start,
																children: [
																	Text('ID:', style: TextStyle(fontSize: 16, color: Colors.grey)),
																	SizedBox(width: 8),
																	Text('e3a7c9b2f4d84a1c9e6b7d2a5f8c3e1b', style: TextStyle(fontSize: 16, color: Colors.grey)),
																],
															),
														],
								),
							),
						),
						const Spacer(),
						SizedBox(
							width: double.infinity,
							child: ElevatedButton.icon(
								icon: const Icon(Icons.edit),
								label: const Text('Editar perfil'),
								onPressed: () {
									// TODO: Implementar edição de perfil
								},
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.deepPurple,
									padding: const EdgeInsets.symmetric(vertical: 14),
									textStyle: const TextStyle(fontSize: 18),
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
								),
							),
						),
						const SizedBox(height: 16),
					],
				),
			),
		);
	}
}
