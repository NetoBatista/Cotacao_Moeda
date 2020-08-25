import 'package:CotacaoMoeda/components/imagem_bandeira.dart';
import 'package:CotacaoMoeda/historico_moedas/historico.regras.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:CotacaoMoeda/aplicacao/aplicacao.dart';
import 'package:CotacaoMoeda/main.util.dart';

class historico extends StatefulWidget {
  String sigla;
  historico(String sigla) {
    this.sigla = sigla;
  }

  @override
  State<StatefulWidget> createState() {
    return new historicoState(sigla);
  }
}

class historicoState extends State<historico> {
  String sigla;
  historicoState(String sigla) {
    this.sigla = sigla;
  }

  HistoricoRegras regras;
  @override
  initState() {
    super.initState();
    regras = BlocProvider.getBloc<HistoricoRegras>();
    regras.dataFiltroController.text = "";
    regras.obterHistorico(sigla);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                imagemBandeira.obterImagemBandeira(sigla, 40, 40, true),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(aplicacao.nomeProjeto,
                        style: TextStyle(fontSize: 15.0)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'Histórico - ${sigla}',
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                )
              ])
            ],
          ),
        ),
        body: StreamBuilder<bool>(
            stream: regras.refreshHistorico.stream,
            builder: (context, snapshot) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    dataFiltro(),
                    Container(child: listaMoedas()),
                  ],
                ),
              );
            }),
        bottomSheet: mainUtil.anuncio);
  }

  Widget dataFiltro() {
    return Container(
      width: 110,
      child: TextField(
        focusNode: FocusNode(skipTraversal: true),
          onChanged: (value) {
            regras.obterHistorico(widget.sigla);
          },
          decoration: InputDecoration(
            labelText: 'Filtro por data',
            hintText: "Ex: 01/01/2020",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
          keyboardType: TextInputType.number,
          controller: regras.dataFiltroController,
          maxLength: 10,
          inputFormatters: [regras.maskFormatter]),
    );
  }

  Widget listaMoedas() {
    if (regras.listaHistorico == null || regras.listaHistorico.length == 0) {
      return Center(
        child: Text("Nenhum dado encontrado."),
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 100),
        physics: NeverScrollableScrollPhysics(),
        itemCount: regras.listaHistorico.length,
        itemBuilder: (BuildContext context, int index) {
          var moedaIndex = regras.listaHistorico[index];
          return ListTile(
            subtitle: Text(
                "Valor de compra: ${moedaIndex.his_valor_compra} \nValor de venda: ${moedaIndex.his_valor_venda}"),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${moedaIndex.his_data}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                Text(
                  "${moedaIndex.his_nome}(${moedaIndex.his_sigla}) - ${aplicacao.cifrao}: ${moedaIndex.his_valor_compra}",
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
          );
        });
  }
}
