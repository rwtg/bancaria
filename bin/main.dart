import 'dart:io';

import 'package:conta_bancaria/conta_bancaria.dart';

void main() {
  print('--- Cadastro do cliente ---');
  stdout.write('Nome: ');
  final nome = stdin.readLineSync() ?? '';
  stdout.write('CPF (11 dígitos): ');
  final cpf = stdin.readLineSync() ?? '';
  stdout.write('E-mail: ');
  final email = stdin.readLineSync() ?? '';

  if (!ContaBancaria.validarDadosCliente(nome: nome, cpf: cpf, email: email)) {
    print('Dados inválidos. Encerrando.');
    return;
  }

  final cliente = ContaBancaria.cadastrarCliente(nome: nome, cpf: cpf, email: email);
  final conta = ContaBancaria(cliente);
  print('Cliente cadastrado com sucesso.');

  print('\n--- Primeiro acesso ---');
  stdout.write('Crie uma senha (mín. 6 caracteres): ');
  final novaSenha = stdin.readLineSync() ?? '';
  try {
    print(conta.criarSenha(novaSenha));
  } catch (e) {
    print('Erro: $e');
    return;
  }

  print('\n--- Depósito inicial ---');
  stdout.write('Valor a depositar: ');
  final valorDeposito = double.tryParse(stdin.readLineSync() ?? '') ?? -1;
  print(conta.depositar(valorDeposito));

  var continuar = true;
  while (continuar) {
    print('\n--- Menu ---');
    final opcoes = conta.menu();
    for (var i = 0; i < opcoes.length; i++) {
      print('${i + 1}. ${opcoes[i]}');
    }
    print('4. Sair');
    stdout.write('Escolha uma opção: ');
    final escolha = stdin.readLineSync();

    switch (escolha) {
      case '1':
        stdout.write('Valor do pagamento: ');
        final valor = double.tryParse(stdin.readLineSync() ?? '') ?? -1;
        stdout.write('Destinatário: ');
        final destinatario = stdin.readLineSync() ?? '';

        final pagamento = conta.criarPagamento(valor: valor, destinatario: destinatario);
        print(conta.processarPagamento(pagamento));

        try {
          print(conta.enviarComprovante(pagamento));
        } catch (e) {
          print('Comprovante não disponível: $e');
        }
        break;

      case '2':
        print('Saldo atual: ${conta.consultarSaldo()}');
        break;

      case '3':
        final pagamentos = conta.consultarPagamentos();
        if (pagamentos.isEmpty) {
          print('Nenhum pagamento realizado.');
        } else {
          for (final p in pagamentos) {
            print('Valor: ${p.valor}, Destinatário: ${p.destinatario}, Status: ${p.status}');
          }
        }
        break;

      case '4':
        print(conta.sair());
        continuar = false;
        break;

      default:
        print('Opção inválida.');
    }
  }
}
