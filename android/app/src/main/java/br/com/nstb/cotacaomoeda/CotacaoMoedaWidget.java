package br.com.nstb.cotacaomoeda;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;

public class CotacaoMoedaWidget  extends AppWidgetProvider  {
    RealizarCotacao realizarCotacao;

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        realizarCotacao = new RealizarCotacao(context, appWidgetManager, appWidgetIds);

    }

}


