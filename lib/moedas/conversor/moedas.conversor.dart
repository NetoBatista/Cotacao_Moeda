import 'package:CotacaoMoeda/moedas/conversor/moedas.conversor.regras.dart';
import 'package:CotacaoMoeda/moedas/moedas.regras.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Conversor extends StatefulWidget {
  @override
  _ConversorState createState() => _ConversorState();
}

class _ConversorState extends State<Conversor> {
  moedasRegrasConversor regras;
  moedasRegras regrasMoedas;
  @override
  void initState() {
    super.initState();
    regras = BlocProvider.getBloc<moedasRegrasConversor>();
    regrasMoedas = BlocProvider.getBloc<moedasRegras>();

  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text("Conversor de moeda", textAlign: TextAlign.center),
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[valorConversao(), dropdownConversorMoeda()])
        ]);
  }

  Widget valorConversao() {
    return Container(
      width: 100,
      padding: EdgeInsets.only(right: 15, top: 6.0),
      child: TextFormField(
          onChanged: (value) {
            regras.aplicarConversao();
          },          
          decoration: InputDecoration(
            hintText: "Ex: R\$ 100",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
          controller: regras.valorConversao,
          maxLength: 10,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          keyboardType: TextInputType.numberWithOptions(decimal: true)),
    );
  }

  Widget dropdownConversorMoeda() {
    return StreamBuilder<bool>(
        stream: regras.refreshConversor.stream,
        builder: (context, snapshot) {
          return DropdownButton(
              onChanged: (value) {
                regras.conversorSelecionado = value;
                regras.aplicarConversao();
                regras.refreshConversor.add(true);
              },
              value: regras.conversorSelecionado,
              hint: Text("Tipo de conversão"),
              items: regras.codigoConversor
                  .map((value) => DropdownMenuItem(
                      value: value,
                      child: Container(padding: EdgeInsets.only(bottom: 15), child: Text(regras.obterNomeConversor(value)))))
                  .toList());
        });
  }
}
