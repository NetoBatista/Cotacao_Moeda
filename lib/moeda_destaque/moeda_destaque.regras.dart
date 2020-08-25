import 'dart:convert';

import 'package:CotacaoMoeda/bancoDados/configurarBancoDados.dart';
import 'package:CotacaoMoeda/bancoDados/moeda_destaque.dart';
import 'package:CotacaoMoeda/moedas/conversor/moedas.conversor.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.simbolos.dart';
import 'package:CotacaoMoeda/moedas/moedas.modelo.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class moeda_destaqueRegras implements BlocBase {
  BehaviorSubject<bool> carregandoDados = new BehaviorSubject<bool>();
  BehaviorSubject<bool> refreshDestaque = new BehaviorSubject<bool>();
  moedaModelo moeda;

  Future<String> obterSiglaDestaque() async {
    var sigla = await new moeda_destaque().obterDestaque();
    return sigla == null ? null : sigla.moe_sigla;
  }

  Future<void> deletarDestaque(){
    moeda = null;
    carregandoDados.add(false);
    new moeda_destaque().deletarDestaque();
    BlocProvider.getBloc<moedasRegras>().aplicarRegraVisibilidade();
  }

  void validarBancoLocal() async {
    if(configurarBancoDados.dataBase == null){
      await new configurarBancoDados().iniciar();
    }
  }

  void obterDadosDestaque() async {
    await validarBancoLocal();
    var siglaDestaque = await obterSiglaDestaque();
    if(siglaDestaque == null){
      return;
    }

    carregandoDados.add(true);
    moeda = null;
    http.get("https://economia.awesomeapi.com.br/json/all/$siglaDestaque-BRL")
        .then((value) {
      if(value.body == null || value.body == ""){
        carregandoDados.add(false);
        return;
      }

      Map<String, dynamic> retornoMoedas = json.decode(value.body);
      retornoMoedas.forEach((key, value) {
        moeda = new moedaModelo().jsonToMoeda(value, key);
        moeda.simboloMoeda = moedaSimbolo.obterSimboloMoeda(moeda.sigla);
        BlocProvider.getBloc<moedasRegrasConversor>().aplicarConversaoDestaque();
        carregandoDados.add(false);
      });
      
      BlocProvider.getBloc<moedasRegras>().aplicarRegraVisibilidade();
    });
  }

  @override
  void addListener(listener) {
  }

  @override
  void dispose() {
  }

  @override
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {
  }

  @override
  void removeListener(listener) {
  }
}