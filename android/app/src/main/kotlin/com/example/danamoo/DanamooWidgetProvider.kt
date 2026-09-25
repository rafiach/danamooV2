package com.example.danamoo

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class DanamooWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val amountLabel = widgetData.getString("pending_amount_label", "Rp 0")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add)
            views.setTextViewText(R.id.tv_amount, amountLabel)

            fun bind(viewId: Int, uri: String) {
                views.setOnClickPendingIntent(
                    viewId,
                    HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(uri))
                )
            }

            bind(R.id.btn_add_1k, "danamoo://add_amount?value=1000")
            bind(R.id.btn_add_5k, "danamoo://add_amount?value=5000")
            bind(R.id.btn_add_10k, "danamoo://add_amount?value=10000")
            bind(R.id.btn_add_50k, "danamoo://add_amount?value=50000")
            bind(R.id.btn_reset, "danamoo://reset_amount")
            bind(R.id.btn_cat_food, "danamoo://save_expense?category=exp_1")
            bind(R.id.btn_cat_transport, "danamoo://save_expense?category=exp_2")
            bind(R.id.btn_cat_shopping, "danamoo://save_expense?category=exp_3")
            bind(R.id.btn_cat_other, "danamoo://save_expense?category=exp_7")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}