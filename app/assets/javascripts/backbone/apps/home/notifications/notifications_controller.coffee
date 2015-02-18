@AlumNet.module 'HomeApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
  class Notifications.Controller
    showCurrentUserNotifications: ->
      notifications = AlumNet.request('notifications:get', {})
      notificationsView = new Notifications.NotificationsView
        collection: notifications
      AlumNet.mainRegion.show(notificationsView)

