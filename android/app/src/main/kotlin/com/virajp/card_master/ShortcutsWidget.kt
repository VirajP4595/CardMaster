package com.virajp.card_master

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Home-screen widget with two shortcuts: "Add expense" and "Best card".
 * It shows no card or money data, so nothing sensitive sits on the home
 * screen while the phone is unlocked by someone else.
 */
class ShortcutsWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.widget_shortcuts)
            views.setOnClickPendingIntent(R.id.widget_add, open(context, "/quick-add", 1))
            views.setOnClickPendingIntent(R.id.widget_best, open(context, "/best", 2))
            manager.updateAppWidget(id, views)
        }
    }

    private fun open(context: Context, route: String, code: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra(MainActivity.EXTRA_ROUTE, route)
        }
        return PendingIntent.getActivity(
            context, code, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }
}
