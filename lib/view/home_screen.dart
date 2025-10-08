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
          const SizedBox(height: 8),
          Expanded(
            child: _inAndOutList(),
          ),
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
  Widget _inAndOutList(){
    // Exemplo de log dos 30 últimos eventos
    final List<Map<String, String>> log = [
      // Os dados reais viriam de uma fonte dinâmica
      {'name': 'Lucas Silva', 'type': 'checkin', 'time': '10:15', 'date': '07/10/2025'},
      {'name': 'Maria Souza', 'type': 'checkout', 'time': '10:16', 'date': '07/10/2025'},
      {'name': 'João Pereira', 'type': 'checkin', 'time': '10:17', 'date': '07/10/2025'},
      {'name': 'Beatriz Lima', 'type': 'checkout', 'time': '10:18', 'date': '07/10/2025'},
      {'name': 'Rafael Costa', 'type': 'checkin', 'time': '10:19', 'date': '07/10/2025'},
      {'name': 'Sofia Martins', 'type': 'checkout', 'time': '10:20', 'date': '07/10/2025'},
      {'name': 'Pedro Alves', 'type': 'checkin', 'time': '10:21', 'date': '07/10/2025'},
      {'name': 'Larissa Rocha', 'type': 'checkout', 'time': '10:22', 'date': '07/10/2025'},
      {'name': 'Gabriel Mendes', 'type': 'checkin', 'time': '10:23', 'date': '07/10/2025'},
      {'name': 'Camila Torres', 'type': 'checkout', 'time': '10:24', 'date': '07/10/2025'},
      {'name': 'Felipe Barros', 'type': 'checkin', 'time': '10:25', 'date': '07/10/2025'},
      {'name': 'Isabela Ramos', 'type': 'checkout', 'time': '10:26', 'date': '07/10/2025'},
      // ... até 30 itens
    ];
    final List<Map<String, String>> logDesc = List.from(log.reversed);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log de presença (últimos 30)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: logDesc.length,
                  separatorBuilder: (context, index) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final item = logDesc[index];
                    final isCheckin = item['type'] == 'checkin';
                    return Row(
                      children: [
                        Icon(
                          isCheckin ? Icons.login : Icons.logout,
                          color: isCheckin ? Colors.green : Colors.red,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['name'] ?? '',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item['date'] ?? '',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item['time'] ?? '',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
