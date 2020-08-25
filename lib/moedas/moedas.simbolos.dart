class moedaSimbolo{
  static String obterSimboloMoeda(String sigla) {
    switch (sigla) {
      case "USD":
        return "\$";
      case "USDT":
        return "\$";
      case "CAD":
        return "\$";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      case "ARS":
        return "\$";
      case "BTC":
        return "₿";
      case "LTC":
        return "Ł";
      case "JPY":
        return "¥";
      case "CHF":
        return "Fr";
      case "AUD":
        return "\$";
      case "CNY":
        return "¥";
      case "ILS":
        return "₪";
      case "ETH":
        return "ETH";
      case "XRP":
        return "XRP";
    }
  }
}