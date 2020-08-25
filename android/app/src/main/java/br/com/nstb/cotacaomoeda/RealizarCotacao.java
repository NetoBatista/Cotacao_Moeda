package br.com.nstb.cotacaomoeda;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.view.View;
import android.widget.RemoteViews;

import com.android.volley.toolbox.JsonRequest;
import com.squareup.picasso.Picasso;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import io.flutter.embedding.android.FlutterActivity;

public class RealizarCotacao extends FlutterActivity {
    Context context;
    AppWidgetManager appWidgetManager;
    int[] appWidgetIds;

    RealizarCotacao(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds){
        this.context = context;
        this.appWidgetManager = appWidgetManager;
        this.appWidgetIds = appWidgetIds;

        AtualizarWidget();
    }

    void AtualizarWidget(){
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(appWidgetId);
        }
    }

    private void updateAppWidget(int appWidgetId) {

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.moeda_widget);
        exibirInformacao("Carregando dados...", views);
        appWidgetManager.updateAppWidget(appWidgetId, views);

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        // Construct an Intent object includes web adresss.
        Intent intent = new Intent(context, MainActivity.class);

        // In widget we are not allowing to use intents as usually. We have to use PendingIntent instead of 'startActivity'
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);

        // Here the basic operations the remote view can do.
        views.setOnClickPendingIntent(R.id.brTo, pendingIntent);
        views.setOnClickPendingIntent(R.id.brFrom, pendingIntent);

        String urlImagem = obterUrlImagem();
        if(urlImagem!= null && urlImagem != "") {
            obterImagens(appWidgetId,views);
            obterImagensCotacao(urlImagem, appWidgetManager, appWidgetId, views);
        }else{
            exibirInformacao("Nenhuma cotação em destaque encontrada.",views);
            appWidgetManager.updateAppWidget(appWidgetId, views);
            return;
        }

        new Thread(() -> {
            try  {
                Thread.sleep(10000);
                realizarCotacao(appWidgetId, views);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();

    }

    String pathBancoDados = "/data/user/0/br.com.nstb.cotacaomoeda/app_flutter/cambio_moeda.db";

    private void exibirInformacao(String informacao, RemoteViews views ){
        views.setTextViewText(R.id.informacaoWidget, informacao);
    }

    private String obterSiglaDestaque(){

        SQLiteDatabase db = SQLiteDatabase.openDatabase(pathBancoDados, null, SQLiteDatabase.OPEN_READONLY);

        Cursor cursor = db.rawQuery("SELECT * FROM moe_moeda_destaque", null);
        if(cursor.moveToFirst()){
            return cursor.getString(cursor.getColumnIndex("moe_sigla"));
        }
        cursor.close();
        db.close();
        return null;
    }

    private String obterSimbolo(){

        SQLiteDatabase db = SQLiteDatabase.openDatabase(pathBancoDados, null, SQLiteDatabase.OPEN_READONLY);

        Cursor cursor = db.rawQuery("SELECT * FROM moe_moeda_destaque", null);
        if(cursor.moveToFirst()){
            return cursor.getString(cursor.getColumnIndex("moe_simbolo"));
        }
        cursor.close();
        db.close();
        return null;
    }

    private String obterUrlImagem(){
        SQLiteDatabase db = SQLiteDatabase.openDatabase(pathBancoDados, null, SQLiteDatabase.OPEN_READONLY);
        Cursor cursor = db.rawQuery("SELECT * FROM moe_moeda_destaque", null);
        if(cursor.moveToFirst()){
            return cursor.getString(cursor.getColumnIndex("moe_url_imagem"));
        }
        cursor.close();
        db.close();
        return null;
    }

    private void realizarCotacao(int appWidgetId, RemoteViews views) throws IOException, JSONException {
        exibirInformacao("Carregando dados...",views);
        String sigla = obterSiglaDestaque();

        BufferedReader reader = null;

        URL url = new URL("https://economia.awesomeapi.com.br/json/all/"+sigla+"-BRL");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();

        con.setConnectTimeout(60000);

        StringBuilder sb = new StringBuilder();
        reader = new BufferedReader(new InputStreamReader(con.getInputStream()));

        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line + "\n");
        }

        reader.close();
        con.disconnect();

        JSONObject dadosCotacao = new JSONObject(sb.toString());
        String dadosSiglaJSON = dadosCotacao.getString(sigla);
        JSONObject dadosSigla = new JSONObject(dadosSiglaJSON);
        runOnUiThread(() -> {
            try {
                String valorCompra = dadosSigla.getString("bid");
                atualizarValores(Double.parseDouble(valorCompra), views);
                atualizarDataExecucao(views);
                exibirInformacao("Dados atualizados a cada 30 minutos.", views);
                appWidgetManager.updateAppWidget(appWidgetId, views);
            }catch(Exception ex){

            }
        });

    }

    private void atualizarValores(Double valorCotacao, RemoteViews views){
        DecimalFormat decimalFormat = new DecimalFormat("0.00");
        views.setTextViewText(R.id.valorBrasilParaMoeda, "R$ "+ decimalFormat.format(valorCotacao));

        String simbolo = obterSimbolo();
        double valorMoedaParaBrasil = (1.0 / valorCotacao);
        views.setTextViewText(R.id.valorMoedaParaBrasil, simbolo + " " + decimalFormat.format(valorMoedaParaBrasil));
    }

    private void atualizarDataExecucao(RemoteViews views){
        Date dataHoraAtual = new Date();
        String data = new SimpleDateFormat("dd/MM/yyyy").format(dataHoraAtual);
        String hora = new SimpleDateFormat("HH:mm:ss").format(dataHoraAtual);

        views.setTextViewText(R.id.ultimaAtualizacao,data + " - " + hora);
    }

    private void obterImagens(int appWidgetId,RemoteViews views){
        String urlImagemBrasil = "https://cdn.pixabay.com/photo/2017/12/06/11/03/brazil-3001462_960_720.png";

        Picasso.get()
                .load(urlImagemBrasil)
                .into(views,R.id.imagemMoedaBrasil,new int[appWidgetId],new com.squareup.picasso.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(Exception ex) {
                    }
                });

        Picasso.get()
                .load(urlImagemBrasil)
                .into(views,R.id.imagemMoedaBrasil2,new int[appWidgetId],new com.squareup.picasso.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(Exception ex) {
                    }
                });

    }

    private void obterImagensCotacao(String urlCotacao, AppWidgetManager appWidgetManager, int appWidgetId,RemoteViews views){
        Picasso.get()
                .load(urlCotacao)
                .into(views,R.id.imagemMoedaCotacao,new int[appWidgetId],new com.squareup.picasso.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(Exception ex) {
                    }
                });

        Picasso.get()
                .load(urlCotacao)
                .into(views,R.id.imagemMoedaCotacao2,new int[appWidgetId],new com.squareup.picasso.Callback() {
                    @Override
                    public void onSuccess() {
                    }

                    @Override
                    public void onError(Exception ex) {
                    }
                });

    }

}
