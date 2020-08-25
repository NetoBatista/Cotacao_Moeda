import 'dart:convert';
import 'package:CotacaoMoeda/bancoDados/historico_cambio_moeda.dart';
import 'package:CotacaoMoeda/bancoDados/moeda_destaque.dart';
import 'package:CotacaoMoeda/moeda_destaque/moeda_destaque.regras.dart';
import 'package:CotacaoMoeda/moedas/conversor/moedas.conversor.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.bandeiras.dart';
import 'package:CotacaoMoeda/moedas/moedas.modelo.dart';
import 'package:CotacaoMoeda/moedas/moedas.simbolos.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class moedasRegras implements BlocBase {
  BehaviorSubject<bool> refreshListaMoedas = new BehaviorSubject();
  BehaviorSubject<bool> carregandoDados = new BehaviorSubject<bool>();
  List<moedaModelo> listaMoeda = new List<moedaModelo>();
  moedasRegrasConversor moedaConversorRegras;

  void incluirComoDestaque(String sigla) {
    var moedaDestaque = new moeda_destaque();
    moedaDestaque.moe_sigla = sigla;
    moedaDestaque.moe_url_imagem = moedasBandeiras.obterBandeira(sigla);
    moedaDestaque.moe_simbolo = moedaSimbolo.obterSimboloMoeda(sigla);
    var retorno = moedaDestaque.inserirDestaque();
    retorno.then((value) {
      Fluttertoast.showToast(
          msg: '$sigla foi salvo como destaque', timeInSecForIos: 3);
      BlocProvider.getBloc<moeda_destaqueRegras>().obterDadosDestaque();
    });
  }

  void carregarListaDeCambio() {
    listaMoeda.clear();
    carregandoDados.add(true);
    BlocProvider.getBloc<moeda_destaqueRegras>().obterDadosDestaque();
    http.get("https://economia.awesomeapi.com.br/json/all").then((value) {
      if (value.body == null || value.body == "") {
        carregandoDados.add(false);
        return;
      }

      Map<String, dynamic> retornoMoedas = json.decode(value.body);
      retornoMoedas.forEach((key, value) {
        var modelo = new moedaModelo().jsonToMoeda(value, key);
        modelo.simboloMoeda = moedaSimbolo.obterSimboloMoeda(modelo.sigla);
        listaMoeda.add(modelo);
        registrarHistorico(modelo);
      });
      moedaConversorRegras.aplicarConversao();
      carregandoDados.add(false);
    });
  }

  String obterTextoPrincipalMoeda(moedaModelo moedaIndex) {
    var simbolo = moedaConversorRegras.conversorSelecionado == 0
        ? "R\$"
        : moedaIndex.simboloMoeda;
    return "${moedaIndex.nome}(${moedaIndex.sigla}) - ${simbolo}: ${moedaIndex.valorCompra}";
  }

  void registrarHistorico(moedaModelo moeda) async {
    var historico = new historico_cambio_moeda();
    historico.his_data = formatarData(DateTime.now().toLocal());
    historico.his_sigla = moeda.sigla;
    historico.his_nome = moeda.nome;
    historico.his_valor_venda = moeda.valorVenda;
    historico.his_valor_compra = moeda.valorCompra;
    historico.inserirHistorico();
  }

  String formatarData(DateTime data) {
    return "${formatarStringData(data.day)}/${formatarStringData(data.month)}/${data.year} - ${formatarStringData(data.hour)}:${formatarStringData(data.minute)}:${formatarStringData(data.second)}";
  }

  String formatarStringData(int data) {
    if (data < 10) {
      return "0$data";
    }
    return data.toString();
  }

  void aplicarRegraVisibilidade() {
    var moedaDestaqueRegras = BlocProvider.getBloc<moeda_destaqueRegras>();
    var destaque = moedaDestaqueRegras.moeda;
    for (var index = 0; index < listaMoeda.length; index++) {
      listaMoeda.elementAt(index).moedaVisivel = destaque == null ||
          destaque.sigla != listaMoeda.elementAt(index).sigla;
    }

    refreshListaMoedas.add(true);
  }

  void exibirNovidade(BuildContext context) async {
    var shared = await SharedPreferences.getInstance();
    var novidadeWidgetLida = shared.getBool("novidade_widget_lida");
    if (novidadeWidgetLida == true) {
      return;
    }
    try{
      BlocProvider.getBloc<moeda_destaqueRegras>().validarBancoLocal();
      var siglaDestaque = await BlocProvider.getBloc<moeda_destaqueRegras>().obterSiglaDestaque();
      if(siglaDestaque != null){
        await BlocProvider.getBloc<moeda_destaqueRegras>().deletarDestaque();
        incluirComoDestaque(siglaDestaque);
      }
    }catch(error){
      
    }

    showDialog(
        context: context,
        child: AlertDialog(
            title: Container(child: Center(child: Text('Novidades'))),
            actions: <Widget>[
              Container(
                width: 100,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text('Entendi'),
                  onPressed: () {
                    shared.setBool('novidade_widget_lida', true);
                    Navigator.pop(context);
                  },
                ),
              )
            ],
            content: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    ' É possível colocar este app como Widget em sua tela principal.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Obs: Sua moeda de sua preferência deve estar como destaque',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                Flexible(
                    child: Image(
                        image: AssetImage('images/imagemExemploWidget.png')))
              ],
            )));
  }

  @override
  void dispose() {}

  @override
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {}

  @override
  void removeListener(listener) {}

  @override
  void addListener(listener) {}
}
