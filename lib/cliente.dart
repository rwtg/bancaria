class Cliente {
  final String nome;
  final String cpf;
  final String email;
  String? senha;
  bool primeiroAcesso;

  Cliente({
    required this.nome,
    required this.cpf,
    required this.email,
    this.senha,
    this.primeiroAcesso = true,
  });
}
