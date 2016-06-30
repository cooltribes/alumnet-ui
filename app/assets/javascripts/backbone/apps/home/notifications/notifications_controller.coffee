@AlumNet.module 'HomeApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
  class Notifications.Controller
    showCurrentUserNotifications: ->
      notifications = AlumNet.request('notifications:get', { page: 1, per_page: 30 })
      notifications.markAllAsRead() #costoso
      notifications.on "fetch:success", ->
      	notifications.firstNotification()
      notificationsView = new Notifications.NotificationsView
        collection: notifications
      AlumNet.mainRegion.show(notificationsView)
      AlumNet.execute 'show:footer'
      #AlumNet.execute('render:home:submenu')

    showCurrentUserRequests: ->
      notifications = AlumNet.request('requests:get', { page: 1, per_page: 30 })
      notifications.markAllAsRead() #costoso
      notifications.on "fetch:success", ->
        notifications.firstNotification()
        notificationsView = new Notifications.NotificationsView
          collection: notifications
        AlumNet.mainRegion.show(notificationsView)
      AlumNet.execute 'show:footer'
      #AlumNet.execute('render:home:submenu')

