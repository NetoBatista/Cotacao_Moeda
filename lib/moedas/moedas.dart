import 'package:CotacaoMoeda/components/imagem_bandeira.dart';
import 'package:CotacaoMoeda/historico_moedas/historico.dart';
import 'package:CotacaoMoeda/moeda_destaque/moeda_destaque.dart';
import 'package:CotacaoMoeda/moeda_destaque/moeda_destaque.regras.dart';
import 'package:CotacaoMoeda/moedas/conversor/moedas.conversor.dart';
import 'package:CotacaoMoeda/moedas/conversor/moedas.conversor.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.regras.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:CotacaoMoeda/main.util.dart';

class moeda extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new moedaState();
  }
}

class moedaState extends State<moeda> {
  moedasRegras regras;
  moeda_destaque moedaDestaque;
  moeda_destaqueRegras moedaDestaqueRegras;
  moedaState() {
    moedaDestaqueRegras = BlocProvider.getBloc<moeda_destaqueRegras>();
  }
  @override
  initState() {
    moedaDestaque = new moeda_destaque();
    regras = BlocProvider.getBloc<moedasRegras>();
    regras.moedaConversorRegras = BlocProvider.getBloc<moedasRegrasConversor>();
    regras.carregarListaDeCambio();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainUtil.refreshAnuncio.add(true);
      Future.delayed(const Duration(seconds: 3), () {
        regras.exibirNovidade(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mainUtil.gerarAnuncio(MediaQuery.of(context).size.width);
    return Column(children: <Widget>[destaque(), Conversor(), body()]);
  }

  Widget destaque() {
    return StreamBuilder<bool>(
        stream: moedaDestaqueRegras.carregandoDados.stream,
        builder: (context, snapshot) {
          return Container(
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            child: moedaDestaque.montarDestaque(),
          );
        });
  }

  Widget body() {
    return StreamBuilder<bool>(
        stream: regras.carregandoDados.stream,
        builder: (context, snapshot) {
          if (regras.carregandoDados.value == true) {
            return Container(
                padding: EdgeInsets.only(top: 15.0),
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.grey)),
                ));
          }
          return listaMoedas();
        });
  }

  Widget listaMoedas() {
    return StreamBuilder<bool>(
        stream: regras.refreshListaMoedas.stream,
        builder: (context, snapshot) {
          return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 100.0),
              itemCount: regras.listaMoeda.length,
              itemBuilder: (BuildContext context, int index) {
                var moedaIndex = regras.listaMoeda[index];
                if (moedaIndex.moedaVisivel == false) {
                  return Container(height: 1, width: 1);
                }
                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  subtitle: Text(
                      "Valor de compra: ${moedaIndex.valorCompra} \nValor de venda: ${moedaIndex.valorVenda}"),
                  title: Text(regras.obterTextoPrincipalMoeda(moedaIndex)),
                  leading: imagemBandeira.obterImagemBandeira(
                      moedaIndex.sigla, 50, 50, true),
                  onLongPress: () {
                    regras.incluirComoDestaque(moedaIndex.sigla);
                  },
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => historico(moedaIndex.sigla)));
                  },
                );
              });
        });
  }
}
