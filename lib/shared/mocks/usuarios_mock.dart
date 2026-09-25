class UsuarioMock {
  final String email;
  final String senha;

  const UsuarioMock({required this.email, required this.senha});
}

const usuariosMock = [
  UsuarioMock(email: 'bruno@gmail.com', senha: 'Bruno12345'),
  UsuarioMock(email: 'arthur@gmail.com', senha: 'Arthur12345'),
  UsuarioMock(email: 'gabril@gmail.com', senha: 'Gabril12345'),
  UsuarioMock(email: 'luciano@gmail.com', senha: 'Luciano12345'),
];
