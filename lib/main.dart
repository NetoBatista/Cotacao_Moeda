import 'package:CotacaoMoeda/aplicacao/aplicacao.dart';
import 'package:CotacaoMoeda/bancoDados/historico_cambio_moeda.dart';
import 'package:CotacaoMoeda/historico_moedas/historico.regras.dart';
import 'package:CotacaoMoeda/main.regras.dart';
import 'package:CotacaoMoeda/moedas/conversor/moedas.conversor.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.dart';
import 'package:CotacaoMoeda/moedas/moedas.regras.dart';
import 'package:CotacaoMoeda/main.util.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'moeda_destaque/moeda_destaque.regras.dart';

void main() {
  runApp(BlocProvider(
      blocs: [Bloc((i) => moedasRegrasConversor()), Bloc((i) => moedasRegras()), Bloc((i) => moeda_destaqueRegras()), Bloc((i) => mainRegras()),  Bloc((i) => HistoricoRegras())],
      child: MyApp()));
  Admob.initialize(mainUtil.getAppId());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          primaryColor: Colors.blueGrey[800]),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  mainRegras regras;
  @override
  void initState() {
    super.initState();
    regras = BlocProvider.getBloc<mainRegras>();
    regras.setTimeExpired();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Center(
                child: Container(
                    child: ButtonTheme(
                        child: FlatButton(
              child: Row(
                children: <Widget>[
                  timer(),
                  SizedBox(width: 10.0),
                  Text(
                    'Limpar Historico',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              onPressed: () {
                new historico_cambio_moeda().deletarHistorico();
              },
            ))))
          ],
          title: Text(
            aplicacao.nomeProjeto,
            style: TextStyle(fontSize: 15.0),
          ),
        ),
        body:  SingleChildScrollView(child: moeda()),
        bottomSheet: StreamBuilder<bool>(
            stream: mainUtil.refreshAnuncio.stream,
            builder: (context, snapshot) {
              return mainUtil.anuncio;
            }));
  }

    Widget timer() {
    return StreamBuilder(
        stream: regras.gettimerShow,
        builder: (context, snapshot) {
          
          if(snapshot.data == "00:00"){
            regras.setTimeExpired();
            BlocProvider.getBloc<moedasRegras>().carregarListaDeCambio();
          }

          regras.refreshTimer();
          
          return Text(snapshot.data ?? "");
        });
  }
}
