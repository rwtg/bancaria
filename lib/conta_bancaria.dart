import 'cliente.dart';
import 'pagamento.dart';

class ContaBancaria {
  final Cliente cliente;
  double saldo = 0;
  final List<Pagamento> pagamentos = [];
  bool sessaoAtiva = true;

  ContaBancaria(this.cliente);

  static bool validarDadosCliente({
    required String nome,
    required String cpf,
    required String email,
  }) {
    final cpfValido = RegExp(r'^\d{11}$').hasMatch(cpf);
    final emailValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return nome.trim().isNotEmpty && cpfValido && emailValido;
  }

  static Cliente cadastrarCliente({
    required String nome,
    required String cpf,
    required String email,
  }) {
    if (!validarDadosCliente(nome: nome, cpf: cpf, email: email)) {
      throw ArgumentError('Dados do cliente inválidos');
    }
    return Cliente(nome: nome, cpf: cpf, email: email);
  }

  String criarSenha(String novaSenha) {
    if (!cliente.primeiroAcesso) {
      throw StateError('Senha já foi definida anteriormente');
    }
    if (novaSenha.length < 6) {
      throw ArgumentError('A senha deve ter ao menos 6 caracteres');
    }
    cliente.senha = novaSenha;
    cliente.primeiroAcesso = false;
    return 'Senha criada com sucesso';
  }

  bool validarValor(double valor) => valor > 0;

  String depositar(double valor) {
    if (!validarValor(valor)) {
      return 'Valor inválido para depósito';
    }
    saldo += valor;
    return 'Depósito de $valor realizado com sucesso';
  }

  List<String> menu() => const ['Pagamento', 'Saldo', 'Consultar pagamentos'];

  double consultarSaldo() => saldo;

  Pagamento criarPagamento({required double valor, required String destinatario}) {
    final pagamento = Pagamento(valor: valor, destinatario: destinatario);
    pagamentos.add(pagamento);
    return pagamento;
  }

  bool validarPagamento(Pagamento pagamento) => saldo >= pagamento.valor;

  String processarPagamento(Pagamento pagamento) {
    if (validarPagamento(pagamento)) {
      saldo -= pagamento.valor;
      pagamento.status = StatusPagamento.aceito;
      return 'Pagamento de ${pagamento.valor} aceito. Saldo atual: ${consultarSaldo()}';
    }
    pagamento.status = StatusPagamento.recusado;
    return 'Pagamento de ${pagamento.valor} recusado por saldo insuficiente';
  }

  List<Pagamento> consultarPagamentos() => List.unmodifiable(pagamentos);

  String enviarComprovante(Pagamento pagamento) {
    if (pagamento.status != StatusPagamento.aceito) {
      throw StateError('Comprovante disponível apenas para pagamentos aceitos');
    }
    return 'Comprovante do pagamento de ${pagamento.valor} enviado para ${cliente.email}';
  }

  String sair() {
    sessaoAtiva = false;
    return 'Sessão encerrada com sucesso';
  }
}
