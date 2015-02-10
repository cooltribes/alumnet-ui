@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Notification extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/me/notifications'

  class Entities.NotificationsCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/me/notifications'
    model: Entities.Notification


  API =
    getNotifications: (querySearch)->
      notifications = new Entities.NotificationsCollection
      notifications.fetch
        data: querySearch
        success: (model, response, options)->
          model.trigger 'fetch:success'
        error: (model, response, options)->
          model.trigger 'fetch:error'
      notifications

  AlumNet.reqres.setHandler 'notifications:get', (querySearch)->
    API.getNotifications(querySearch)
