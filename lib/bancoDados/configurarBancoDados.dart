import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class configurarBancoDados {
  static Database dataBase;
  void iniciar() async {
    if (dataBase != null) {
      return;
    }
    var retorno = await criarTabelasBanco();
    //retorno.then((value) => dataBase = value);
    dataBase = retorno;
  }

  Future<Database> criarTabelasBanco() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'cambio_moeda.db');
    var dataBaseRetorno =
        await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE his_historico_cambio_moeda(his_id INTEGER PRIMARY KEY, his_nome TEXT, his_sigla TEXT, his_valor_compra TEXT, his_valor_venda TEXT, his_data TEXT)",
      );
      await db.execute(
        "CREATE TABLE moe_moeda_destaque (moe_id INTEGER PRIMARY KEY, moe_sigla TEXT, moe_url_imagem TEXT, moe_simbolo TEXT)",
      );
    }, onUpgrade: (dataBase, oldVersion, newVersion) {
      dataBase.execute(
          "ALTER TABLE moe_moeda_destaque ADD COLUMN moe_url_imagem TEXT");
      dataBase.execute(
          "ALTER TABLE moe_moeda_destaque ADD COLUMN moe_simbolo TEXT");
    });
    return dataBaseRetorno;
  }
}
