import 'package:test/test.dart';
import 'package:conta_bancaria/cliente.dart';
import 'package:conta_bancaria/pagamento.dart';
import 'package:conta_bancaria/conta_bancaria.dart';

void main() {
  group('Critério 1 - Cadastro do cliente', () {
    test('Dado dados válidos, quando cadastro, então cliente é criado', () {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'caua@email.com',
      );

      expect(cliente.nome, 'Caua');
      expect(cliente.primeiroAcesso, isTrue);
    });
  });

  group('Critério 2 - Validação dos dados do cliente', () {
    test('Dado CPF inválido, quando valida, então retorna falso', () {
      final valido = ContaBancaria.validarDadosCliente(
        nome: 'Vinicios',
        cpf: '123',
        email: 'caua@email.com',
      );

      expect(valido, isFalse);
    });

    test('Dado e-mail inválido, quando valida, então retorna falso', () {
      final valido = ContaBancaria.validarDadosCliente(
        nome: 'caua',
        cpf: '12345678901',
        email: 'caua-email.com',
      );

      expect(valido, isFalse);
    });

    test('Dado dados inválidos, quando cadastra, então lança exceção', () {
      expect(
        () => ContaBancaria.cadastrarCliente(nome: '', cpf: '123', email: 'invalido'),
        throwsArgumentError,
      );
    });
  });

  group('Critério 3 - Primeiro acesso exige criação de senha', () {
    late ContaBancaria conta;

    setUp(() {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'caua',
        cpf: '12345678901',
        email: 'caua@email.com',
      );
      conta = ContaBancaria(cliente);
    });

    test('Dado primeiro acesso, quando cria senha válida, então senha é definida', () {
      final resultado = conta.criarSenha('senha123');

      expect(resultado, 'Senha criada com sucesso');
      expect(conta.cliente.primeiroAcesso, isFalse);
    });

    test('Dado senha curta, quando cria senha, então lança exceção', () {
      expect(() => conta.criarSenha('123'), throwsArgumentError);
    });

    test('Dado senha já criada, quando tenta criar novamente, então lança exceção', () {
      conta.criarSenha('senha123');

      expect(() => conta.criarSenha('outraSenha'), throwsStateError);
    });
  });

  group('Critérios 4 e 5 - Inserção e validação do valor na conta', () {
    late ContaBancaria conta;

    setUp(() {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'vinicios@email.com',
      );
      conta = ContaBancaria(cliente);
    });

    test('Dado valor positivo, quando deposita, então saldo é atualizado', () {
      final resultado = conta.depositar(100);

      expect(resultado, contains('sucesso'));
      expect(conta.consultarSaldo(), 100);
    });

    test('Dado valor negativo ou zero, quando deposita, então retorna erro e saldo não muda', () {
      final resultado = conta.depositar(-50);

      expect(resultado, 'Valor inválido para depósito');
      expect(conta.consultarSaldo(), 0);
    });
  });

  group('Critério 6 - Menu de opções', () {
    test('Quando consulta o menu, então retorna pagamento, saldo e consultar pagamentos', () {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'vinicios@email.com',
      );
      final conta = ContaBancaria(cliente);

      expect(conta.menu(), ['Pagamento', 'Saldo', 'Consultar pagamentos']);
    });
  });

  group('Critérios 7, 8, 9 e 10 - Criação e validação de pagamento', () {
    late ContaBancaria conta;

    setUp(() {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'vinicios@email.com',
      );
      conta = ContaBancaria(cliente);
      conta.depositar(200);
    });

    test('Dado saldo suficiente, quando processa pagamento, então debita e informa cliente', () {
      final pagamento = conta.criarPagamento(valor: 150, destinatario: 'Loja X');

      final resultado = conta.processarPagamento(pagamento);

      expect(pagamento.status, StatusPagamento.aceito);
      expect(conta.consultarSaldo(), 50);
      expect(resultado, contains('aceito'));
    });

    test('Dado saldo insuficiente, quando processa pagamento, então recusa e informa cliente', () {
      final pagamento = conta.criarPagamento(valor: 500, destinatario: 'Loja X');

      final resultado = conta.processarPagamento(pagamento);

      expect(pagamento.status, StatusPagamento.recusado);
      expect(conta.consultarSaldo(), 200);
      expect(resultado, contains('recusado'));
    });
  });

  group('Critério 11 - Consulta de saldo após débito', () {
    test('Dado pagamento aceito, quando consulta saldo, então reflete o novo valor', () {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'vinicios@email.com',
      );
      final conta = ContaBancaria(cliente);
      conta.depositar(300);
      final pagamento = conta.criarPagamento(valor: 100, destinatario: 'Loja Y');

      conta.processarPagamento(pagamento);

      expect(conta.consultarSaldo(), 200);
    });
  });

  group('Critério 12 - Envio do comprovante', () {
    late ContaBancaria conta;

    setUp(() {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'vinicios@email.com',
      );
      conta = ContaBancaria(cliente);
      conta.depositar(100);
    });

    test('Dado pagamento aceito, quando envia comprovante, então retorna mensagem de confirmação', () {
      final pagamento = conta.criarPagamento(valor: 50, destinatario: 'Loja Z');
      conta.processarPagamento(pagamento);

      final comprovante = conta.enviarComprovante(pagamento);

      expect(comprovante, contains('Comprovante'));
    });

    test('Dado pagamento recusado, quando envia comprovante, então lança exceção', () {
      final pagamento = conta.criarPagamento(valor: 500, destinatario: 'Loja Z');
      conta.processarPagamento(pagamento);

      expect(() => conta.enviarComprovante(pagamento), throwsStateError);
    });
  });

  group('Critério 13 - Encerramento da sessão', () {
    test('Quando cliente sai da conta, então sessão é encerrada', () {
      final cliente = ContaBancaria.cadastrarCliente(
        nome: 'Vinicios',
        cpf: '12345678901',
        email: 'vinicios@email.com',
      );
      final conta = ContaBancaria(cliente);

      final resultado = conta.sair();

      expect(resultado, 'Sessão encerrada com sucesso');
      expect(conta.sessaoAtiva, isFalse);
    });
  });
}
