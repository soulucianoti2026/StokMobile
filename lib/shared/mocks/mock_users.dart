class UsersMock {
  final String email;
  final String senha;

  const UsersMock({required this.email, required this.senha});
}

const usuariosMock = [
  UsersMock(email: 'bruno@gmail.com', senha: 'Bruno12345'),
  UsersMock(email: 'arthur@gmail.com', senha: 'Arthur12345'),
  UsersMock(email: 'gabril@gmail.com', senha: 'Gabril12345'),
  UsersMock(email: 'luciano@gmail.com', senha: 'Luciano12345'),
];
