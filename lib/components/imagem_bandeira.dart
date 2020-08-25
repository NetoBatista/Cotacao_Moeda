import 'package:CotacaoMoeda/moedas/moedas.bandeiras.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class imagemBandeira {

  static Widget obterImagemBandeira(String sigla, double width, double heigth, bool transicao) {
    return Hero(
        tag: transicao ? sigla : DateTime.now().millisecond,
        child: ClipOval(
            child: CachedNetworkImage(
          height: heigth,
          width: width,
          fit: BoxFit.fill,
          imageUrl: moedasBandeiras.obterBandeira(sigla),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        )));
  }

}
