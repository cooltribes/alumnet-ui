@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Notification extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/me/notifications'

    markAs:(state)->
      # states read - unread
      self = @
      opts =
        success: ->
          self.markInModel(state)
      @markInApi(state, opts)


    markInModel: (state)->
      if state == "read"
        @set('is_read', true)
      else if state == "unread"
        @set('is_read', false)
      @collection.trigger 'reset'

    markInApi: (state, opts)->
      url = @url() + "/mark_as_#{state}"
      options =
        url: url
        type: 'PUT'
      _.extend(options, opts)
      (@sync || Backbone.sync).call(@, null, @, options)

  class Entities.NotificationsCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/me/notifications'
    model: Entities.Notification

    markAllAsRead: ->
      self = @
      opts =
        success: ->
          self.markAllReadInCollection()
      @markAllReadInApi(opts)

    markAllReadInCollection: ->
      @invoke('set', { is_read: true })
      @trigger 'reset'

    markAllReadInApi: (opts)->
      url = @url() + '/mark_all_read'
      options =
        url: url
        type: 'PUT'
      _.extend(options, opts)
      (@sync || Backbone.sync).call(@, null, @, options)



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