import 'package:CotacaoMoeda/bancoDados/historico_cambio_moeda.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rxdart/rxdart.dart';

class HistoricoRegras implements BlocBase {
  BehaviorSubject<bool> refreshHistorico = new BehaviorSubject<bool>();
  List<historico_cambio_moeda> listaHistorico =new List<historico_cambio_moeda>();
  TextEditingController dataFiltroController = new TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });


  void obterHistorico(String sigla){
    var dataFiltro = dataFiltroController.text ?? "";
    var retorno = new historico_cambio_moeda().obterHistorico(sigla);
    retorno.then((List<historico_cambio_moeda> listaSalva) {
      if(listaSalva == null){
        listaHistorico = null;
        return;
      }
        var listaFiltrada = new List<historico_cambio_moeda>();
        for(var index =0 ; index < listaSalva.length; index ++){
          var dataHistorico = dataFiltro == "" ? null : listaSalva.elementAt(index).his_data.substring(0,dataFiltro.length);
          if(dataFiltro == "" || dataHistorico == dataFiltro){
            listaFiltrada.add(listaSalva.elementAt(index));
          }
        }

        listaHistorico = listaFiltrada;
        refreshHistorico.add(true);
    });
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
