import 'package:CotacaoMoeda/moeda_destaque/moeda_destaque.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.regras.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:rxdart/rxdart.dart';

class moedasRegrasConversor implements BlocBase {
  BehaviorSubject<bool> refreshConversor = new BehaviorSubject();
  int conversorSelecionado = 0;
  var codigoConversor = [0, 1];
  MoneyMaskedTextController valorConversao = new MoneyMaskedTextController(
      decimalSeparator: '.', thousandSeparator: ',', initialValue: 0.0);

  String obterNomeConversor(int codigo) {
    switch (codigo) {
      case 0:
        return "Moeda estrangeira -> Brasil";
      case 1:
        return "Brasil -> Moeda estrangeira";
    }
    return '';
  }

  void aplicarConversao() {
    double valor = obterValorConversao();

    var regrasMoedas = BlocProvider.getBloc<moedasRegras>();
    regrasMoedas.listaMoeda.forEach((element) {
      if (conversorSelecionado == 0) {
        element.valorVenda = (double.parse(element.valorVendaOriginal) * valor)
            .toStringAsFixed(2);
        element.valorCompra =
            (double.parse(element.valorCompraOriginal) * valor)
                .toStringAsFixed(2);
      } else {
        element.valorVenda = (valor / double.parse(element.valorVendaOriginal))
            .toStringAsFixed(2);
        element.valorCompra =
            (valor / double.parse(element.valorCompraOriginal))
                .toStringAsFixed(2);
      }
    });
    aplicarConversaoDestaque();
    BlocProvider.getBloc<moedasRegras>().refreshListaMoedas.add(true);
    BlocProvider.getBloc<moeda_destaqueRegras>().refreshDestaque.add(true);

  }

  double obterValorConversao() {
    var valorTexto = valorConversao.text.replaceAll(',', '');
    if (valorTexto == "" ||
        valorTexto == null ||
        double.tryParse(valorTexto) == null ||
        double.parse(valorTexto) == 0) {
      return 1;
    } else {
      return double.parse(valorTexto);
    }
  }

  void aplicarConversaoDestaque() {
    var destaqueRegras = BlocProvider.getBloc<moeda_destaqueRegras>();
    if (destaqueRegras.moeda == null) {
      return;
    }
    var valorConversao = obterValorConversao();
    if (conversorSelecionado == 0) {
      destaqueRegras.moeda.valorVenda =
          (double.parse(destaqueRegras.moeda.valorVendaOriginal) *
                  valorConversao)
              .toStringAsFixed(2);
      destaqueRegras.moeda.valorCompra =
          (double.parse(destaqueRegras.moeda.valorCompraOriginal) *
                  valorConversao)
              .toStringAsFixed(2);
    } else {
      destaqueRegras.moeda.valorVenda = (valorConversao /
              double.parse(destaqueRegras.moeda.valorVendaOriginal))
          .toStringAsFixed(2);
      destaqueRegras.moeda.valorCompra = (valorConversao /
              double.parse(destaqueRegras.moeda.valorCompraOriginal))
          .toStringAsFixed(2);
    }

    destaqueRegras.refreshDestaque.add(true);
  }

  @override
  void addListener(listener) {}

  @override
  void dispose() {}

  @override
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {}

  @override
  void removeListener(listener) {}
}
