import 'package:CotacaoMoeda/aplicacao/aplicacao.dart';
import 'package:CotacaoMoeda/components/imagem_bandeira.dart';
import 'package:CotacaoMoeda/historico_moedas/historico.dart';
import 'package:CotacaoMoeda/moeda_destaque/moeda_destaque.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.regras.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class moeda_destaque {
  moeda_destaqueRegras regras;

  moeda_destaque() {
    regras = BlocProvider.getBloc<moeda_destaqueRegras>();
    regras.obterDadosDestaque();
  }

  Widget montarDestaque() {
    return StreamBuilder<bool>(
        stream: regras.carregandoDados.stream,
        builder: (context, snapshot) {
          if (regras.carregandoDados.value == true) {
            return Container();
          }
          if (regras.moeda == null) {
            return Container(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Aperte uma vez para ver o histórico de consultas. \nAperte e segure para marcar como destaque \nValores atualizados a cada 3 minutos',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0),
                ),
              ),
            );
          }

          return destaque();
        });
  }

  Widget destaque() {
    return StreamBuilder<bool>(
        stream: regras.refreshDestaque.stream,
        builder: (context, snapshot) {
          return Card(
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: imagemBandeira.obterImagemBandeira(
                        regras.moeda.sigla, 50, 50, false),
                    subtitle: Text(
                      "Valor de compra: ${regras.moeda.valorCompra} \nValor de venda: ${regras.moeda.valorVenda}",
                      style: TextStyle(fontSize: 15),
                    ),
                    title: Text(
                        BlocProvider.getBloc<moedasRegras>()
                            .obterTextoPrincipalMoeda(regras.moeda),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      abrirHistorico(context),
                      removerDestaque()
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  ButtonBar removerDestaque() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          child: const Text(
            'Remover destaque',
            style: TextStyle(fontSize: 15),
          ),
          onPressed: () {
            regras.deletarDestaque();
          },
        )
      ],
    );
  }

  ButtonBar abrirHistorico(BuildContext context) {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          child: const Text(
            'Histórico',
            style: TextStyle(fontSize: 15),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => historico(regras.moeda.sigla)));
          },
        )
      ],
    );
  }
}
