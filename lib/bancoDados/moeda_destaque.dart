import 'package:CotacaoMoeda/bancoDados/configurarBancoDados.dart';
import 'package:sqflite/sqflite.dart';

class moeda_destaque {
  moeda_destaque(
      {this.moe_id, this.moe_sigla, this.moe_url_imagem, this.moe_simbolo});
  int moe_id;
  String moe_sigla;
  String moe_url_imagem;
  String moe_simbolo;

  Map<String, dynamic> historicoToMap() {
    return {
      'moe_id': moe_id,
      'moe_sigla': moe_sigla,
      'moe_url_imagem': moe_url_imagem,
      'moe_simbolo': moe_simbolo
    };
  }

  moeda_destaque mapToMoedaDestaque(Map<String, dynamic> map) {
    return moeda_destaque(
        moe_id: map["moe_id"],
        moe_sigla: map['moe_sigla'],
        moe_url_imagem: map['moe_url_imagem'],
        moe_simbolo: map['moe_simbolo']);
  }

  Future<void> inserirDestaque() async {
    await deletarDestaque();
    final Database db = configurarBancoDados.dataBase;
    db.insert('moe_moeda_destaque', historicoToMap());
  }

  Future<void> deletarDestaque() async {
    final Database db = configurarBancoDados.dataBase;
    await db.delete('moe_moeda_destaque');
  }

  Future<moeda_destaque> obterDestaque() async {
    final Database db = configurarBancoDados.dataBase;
    final List<Map<String, dynamic>> listaMoedaDestaque =
        await db.query("moe_moeda_destaque");
    if (listaMoedaDestaque == null || listaMoedaDestaque.length == 0) {
      return null;
    }

    var moedaDestaque = listaMoedaDestaque[0];

    return mapToMoedaDestaque(moedaDestaque);
  }
}
