@AlumNet.module 'HomeApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
  class Notifications.Controller
    showCurrentUserNotifications: ->
      notifications = AlumNet.request('notifications:get', {})
      notifications.markAllAsRead() #costoso
      notifications.on "fetch:success", ->
      	notifications.firstNotification()
      notificationsView = new Notifications.NotificationsView
        collection: notifications
      AlumNet.mainRegion.show(notificationsView)
      AlumNet.execute('render:home:submenu')


