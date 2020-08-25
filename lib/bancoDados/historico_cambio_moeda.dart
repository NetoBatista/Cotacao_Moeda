import 'package:CotacaoMoeda/bancoDados/configurarBancoDados.dart';
import 'package:sqflite/sqflite.dart';

class historico_cambio_moeda {
  historico_cambio_moeda({this.his_id,this.his_nome,this.his_sigla,this.his_valor_compra,this.his_valor_venda, this.his_data});
  int his_id;
  String his_nome;
  String his_sigla;
  String his_valor_compra;
  String his_valor_venda;
  String his_data;

  Map<String,dynamic> historicoToMap(){
    return {
      'his_id': his_id,
      'his_nome': his_nome,
      'his_sigla': his_sigla,
      'his_valor_compra': his_valor_compra,
      'his_valor_venda': his_valor_venda,
      'his_data': his_data
    };
  }

  historico_cambio_moeda mapToHistorico(Map<String,dynamic> map){
    return historico_cambio_moeda(his_id: map["his_id"], his_nome: map['his_nome'], his_sigla: map['his_sigla'], his_valor_compra: map['his_valor_compra'], his_valor_venda: map['his_valor_venda'], his_data: map['his_data']);
  }
  
  Future<void> inserirHistorico() async {
    final Database db = configurarBancoDados.dataBase;
    db.insert('his_historico_cambio_moeda', historicoToMap());
  }

  Future<void> deletarHistorico() async {
    final Database db = configurarBancoDados.dataBase;
    db.delete('his_historico_cambio_moeda');
  }

  Future<List<historico_cambio_moeda>> obterHistorico(String sigla) async {
    final Database db = configurarBancoDados.dataBase;
    final List<Map<String,dynamic>> historico = await db.rawQuery("SELECT * FROM his_historico_cambio_moeda WHERE his_sigla = '${sigla}' ORDER BY his_id DESC");
    if(historico == null || historico.length == 0) {
      return null;
    }
    var retorno = new List<historico_cambio_moeda>();
    historico.forEach((element) {
      var cambioMoeda = mapToHistorico(element);
      retorno.add(cambioMoeda);
    });

    return retorno;
  }

}