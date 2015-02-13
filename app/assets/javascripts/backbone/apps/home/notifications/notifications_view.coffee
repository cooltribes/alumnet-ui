@AlumNet.module 'HomeApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
  class Notifications.NotificationView extends Marionette.ItemView
    template: 'home/notifications/templates/notification'

    ui:
      'linkMarkRead': '#js-mark-as-read'
      'linkMarkUnRead': '#js-mark-as-unread'
      'linkDelete': '#js-delete'

    events:
      'click @ui.linkMarkRead': 'markAsRead'
      'click @ui.linkMarkUnRead': 'markAsUnRead'
      'click @ui.linkDelete': 'markDelete'

    markDelete: (e)->
      e.preventDefault()
      resp = confirm("Are you Sure?")
      if resp
        @model.destroy()

    markAsRead: (e)->
      e.preventDefault()
      @model.markAs('read')

    markAsUnRead: (e)->
      e.preventDefault()
      @model.markAs('unread')


  class Notifications.NotificationsView extends Marionette.CompositeView
    template: 'home/notifications/templates/notifications_container'
    childView: Notifications.NotificationView
    childViewContainer: ".notifications-container"
    events:
      'click #js-mark-all-read': "markAllAsRead"

    markAllAsRead: (e)->
      e.preventDefault()
      @collection.markAllAsRead()
