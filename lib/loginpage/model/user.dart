class User {
  final String email;
  final String senha;
  final String nome;
  final String documento;
  final String foto;

  User({
    required this.email,
    required this.senha,
    this.nome = '',
    this.documento = '',
    this.foto = '',
  });
}
