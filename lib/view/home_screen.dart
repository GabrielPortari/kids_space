import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> childrenPresent = [
      {
        'childName': 'Lucas Silva',
        'responsibleName': 'Ana Silva',
        'phone': '(11) 91234-5678',
      },
      {
        'childName': 'Maria Souza',
        'responsibleName': 'Carlos Souza',
        'phone': '(11) 99876-5432',
      },
      {
        'childName': 'João Pereira',
        'responsibleName': 'Fernanda Pereira',
        'phone': '(11) 98765-4321',
      },
      {
        'childName': 'Beatriz Lima',
        'responsibleName': 'Paulo Lima',
        'phone': '(11) 91111-2222',
      },
      {
        'childName': 'Rafael Costa',
        'responsibleName': 'Juliana Costa',
        'phone': '(11) 93333-4444',
      },
      {
        'childName': 'Sofia Martins',
        'responsibleName': 'Roberto Martins',
        'phone': '(11) 95555-6666',
      },
      {
        'childName': 'Pedro Alves',
        'responsibleName': 'Patrícia Alves',
        'phone': '(11) 97777-8888',
      },
      {
        'childName': 'Larissa Rocha',
        'responsibleName': 'Marcelo Rocha',
        'phone': '(11) 99999-0000',
      },
      {
        'childName': 'Gabriel Mendes',
        'responsibleName': 'Simone Mendes',
        'phone': '(11) 90000-1111',
      },
      {
        'childName': 'Camila Torres',
        'responsibleName': 'Eduardo Torres',
        'phone': '(11) 92222-3333',
      },
      {
        'childName': 'Felipe Barros',
        'responsibleName': 'Aline Barros',
        'phone': '(11) 94444-5555',
      },
      {
        'childName': 'Isabela Ramos',
        'responsibleName': 'Gustavo Ramos',
        'phone': '(11) 96666-7777',
      },
    ];

    return Column(
      children: [
        _infoCompanyCard(),
        const SizedBox(height: 8),
		_checkInAndOutButtons(),
        _listLabel(childrenPresent, context),
        _childrenPresentList(childrenPresent),
      ],
    );
  }

	Widget _checkInAndOutButtons() {
	return Padding(
	  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
	  child: Row(
		mainAxisAlignment: MainAxisAlignment.spaceEvenly,
		children: [
          ElevatedButton.icon(
            onPressed: () {
              // Ação de check-in
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Check-In', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Ação de check-out
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Check-Out', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
		],
	  ),
	);
  }

  Widget _listLabel(
    List<Map<String, String>> childrenPresent,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Crianças presentes: ${childrenPresent.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/all_active_children');
            },
            child: const Text('Ver mais'),
          ),
        ],
      ),
    );
  }

  Widget _childrenPresentList(List<Map<String, String>> childrenPresent) {
    return SizedBox(
      height: 320,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: childrenPresent.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final child = childrenPresent[index];
              return _childPresentItem(
                childName: child['childName'] ?? '',
                responsibleName: child['responsibleName'] ?? '',
                phone: child['phone'] ?? '',
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _childPresentItem({
    required String childName,
    required String responsibleName,
    required String phone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.child_care, color: Colors.deepPurple, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                childName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Responsável: $responsibleName',
                style: const TextStyle(fontSize: 15),
              ),
              Text(
                'Telefone: $phone',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _infoCompanyCard() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagem circular do logo
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: const AssetImage(
                      'assets/images/company_logo_placeholder.png',
                    ),
                    backgroundColor: Colors.deepPurple[50],
                    child: const Icon(
                      Icons.business,
                      size: 32,
                      color: Colors.deepPurple,
                    ), // caso não tenha imagem
                  ),
                  const SizedBox(width: 20),
                  // Informações da empresa
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tech Kids',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Crianças presentes: 12',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
