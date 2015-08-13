@AlumNet.module 'Shared.Views', (Views, @AlumNet, Backbone, Marionette, $, _) ->
  class Views.UserView extends Marionette.ItemView

    ui:
      'linkContainer': '#link-container'
      'requestLink': '#js-request-friendship'
      'acceptLink': '#js-accept-friendship'
      'rejectLink': '#js-reject-friendship'
      'cancelLink': '#js-cancel-friendship'
      'deleteLink': '#js-delete-friendship'

    events:
      'click #js-request-friendship':'clickedRequest'
      'click #js-accept-friendship':'clickedAccept'
      'click #js-reject-friendship':'clickedReject'
      'click #js-delete-friendship':'clickedDelete'
      'click #js-cancel-friendship':'clickedCancel'


    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      friendship.on 'save:success', (response, options) ->
        AlumNet.current_user.decrementCount('pending_received_friendships')
        AlumNet.current_user.incrementCount('friends')
        self.render()
        self.trigger 'Catch:Up'
      friendship.on 'save:error', (response, options)->
        console.log response.responseJSON

    clickedRequest: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = { friend_id: @model.id }
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      friendship.on 'save:success', (response, options) ->
        AlumNet.current_user.incrementCount('pending_sent_friendships')
        self.trigger 'Catch:Up'
      friendship.on 'save:error', (response, options)->
        console.log response.responseJSON

    clickedReject: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('pending_received_friendships')

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('friends')

    clickedCancel: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('pending_sent_friendships')

    removeCancelLink: ->
      @model.set("friendship_status","none")
      @trigger 'Catch:Up'