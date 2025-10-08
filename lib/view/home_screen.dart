import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _infoCompanyCard(),
          const SizedBox(height: 8),
          _checkInAndOutButtons(),
          const SizedBox(height: 8),
          _activeChildrenInfoCard(childrenPresent),
        ],
      ),
    );
  }

  Widget _activeChildrenInfoCard(List<Map<String, String>> childrenPresent) {
    final int activeCount = childrenPresent.length;
    final Map<String, String> lastCheckIn = {
      'childName': 'Isabela Ramos',
      'time': '10:42',
    };
    final Map<String, String> lastCheckOut = {
      'childName': 'Lucas Silva',
      'time': '10:15',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/all_active_children');
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$activeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const Text(
                          'Ativos',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.login, color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Último check-in:',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                      child: Row(
                        children: [
                          Text(
                            lastCheckIn['childName']!,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lastCheckIn['time']!,
                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Último check-out:',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                      child: Row(
                        children: [
                          Text(
                            lastCheckOut['childName']!,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lastCheckOut['time']!,
                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            label: const Text(
              'Check-In',
              style: TextStyle(color: Colors.white),
            ),
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
            label: const Text(
              'Check-Out',
              style: TextStyle(color: Colors.white),
            ),
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

  Widget _infoCompanyCard() {
    return Builder(
      builder: (context) {
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
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tech Kids',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Colaborador: João Oliveira',
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'id: e3a7c9b2f4d84...',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    child: const Icon(Icons.copy, size: 18, color: Colors.grey),
                                    onTap: () async {
                                      await Clipboard.setData(const ClipboardData(text: 'e3a7c9b2f4d84a1c9e6b7d2a5f8c3e1b'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('ID copiado para a área de transferência!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
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
      },
    );
  }
}
