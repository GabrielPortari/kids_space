// Serviço de colaboradores
import 'package:kids_space/model/collaborator.dart';

class CollaboratorService {
 // Simulação: busca colaborador pelo email
  Future<Collaborator?> getCollaboratorByEmail(String email) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (email == 'admin@admin.com') {
      return Collaborator(
        id: '1',
        name: 'Administrador',
        companyId: 'company1',
      );
    }
    return null;
  }
}
