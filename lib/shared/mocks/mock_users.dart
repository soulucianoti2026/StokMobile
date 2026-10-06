class UsersMock {
  final String email;
  final String senha;

  final String nome;
  final String documento;
  final String foto;

  const UsersMock({
    required this.email,
    required this.senha,
    this.nome = '',
    this.documento = '',
    this.foto = '',
  });

  factory UsersMock.fromJson(Map<String, dynamic> json) => UsersMock(
    email: json['email'] as String,
    senha: json['senha'] as String,
    nome: json['nome'] as String? ?? '',
    documento: json['documento'] as String? ?? '',
    foto: json['foto'] as String? ?? '',
  );

  Map<String, String> toJson() => {
    'email': email,
    'senha': senha,
    'nome': nome,
    'documento': documento,
    'foto': foto,
  };
}

const _initialUsers = [
  UsersMock(email: 'bruno@gmail.com', senha: 'Bruno12345'),
  UsersMock(email: 'arthur@gmail.com', senha: 'Arthur12345'),
  UsersMock(email: 'gabriel@gmail.com', senha: 'Gabriel12345'),
  UsersMock(email: 'luciano@gmail.com', senha: 'Luciano12345'),
];

final List<UsersMock> usuariosMock = [..._initialUsers];
