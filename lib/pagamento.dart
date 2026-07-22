enum StatusPagamento { pendente, aceito, recusado }

class Pagamento {
  final double valor;
  final String destinatario;
  StatusPagamento status;

  Pagamento({
    required this.valor,
    required this.destinatario,
    this.status = StatusPagamento.pendente,
  });
}
