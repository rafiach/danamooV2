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
        val selectedCategory = widgetData.getString("selected_category", null)

        val categoryViews = mapOf(
            "exp_1" to R.id.btn_cat_food,
            "exp_2" to R.id.btn_cat_transport,
            "exp_3" to R.id.btn_cat_shopping,
            "exp_4" to R.id.btn_cat_bill,
            "exp_5" to R.id.btn_cat_entertainment,
            "exp_7" to R.id.btn_cat_other
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add)
            views.setTextViewText(R.id.tv_amount, amountLabel)

            for ((catId, viewId) in categoryViews) {
                val bg = if (catId == selectedCategory) R.drawable.widget_chip_bg_selected else R.drawable.widget_chip_bg
                views.setInt(viewId, "setBackgroundResource", bg)
            }

            fun bind(viewId: Int, uri: String) {
                views.setOnClickPendingIntent(
                    viewId,
                    HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(uri))
                )
            }

            for ((catId, viewId) in categoryViews) {
                bind(viewId, "danamoo://select_category?id=$catId")
            }

            bind(R.id.btn_add_1k, "danamoo://add_amount?value=1000")
            bind(R.id.btn_add_5k, "danamoo://add_amount?value=5000")
            bind(R.id.btn_add_10k, "danamoo://add_amount?value=10000")
            bind(R.id.btn_add_50k, "danamoo://add_amount?value=50000")
            bind(R.id.btn_reset, "danamoo://reset_all")
            bind(R.id.btn_send, "danamoo://send")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}