class moedaModelo{
   String sigla;
   String nome;
   String valorCompra;
   String valorVenda;
   String valorCompraOriginal;
   String valorVendaOriginal;
   String simboloMoeda;
   bool moedaVisivel;

   moedaModelo jsonToMoeda(Map<String, dynamic> json, String sigla){
     var retorno = new moedaModelo();
     retorno.nome = json["name"] as String;
     retorno.valorCompra =  double.parse(json["bid"]).toStringAsFixed(2);
     retorno.valorVenda = double.parse(json["ask"]).toStringAsFixed(2);
     retorno.valorCompraOriginal = retorno.valorCompra;
     retorno.valorVendaOriginal = retorno.valorVenda;
     retorno.sigla = sigla;
     retorno.moedaVisivel = true;
     return retorno;
   }
}

