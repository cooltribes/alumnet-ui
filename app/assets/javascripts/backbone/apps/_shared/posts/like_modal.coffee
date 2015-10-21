@AlumNet.module 'Shared.Views', (Views, @AlumNet, Backbone, Marionette, $, _) ->
  class Views.LikesModal extends Backbone.Modal
    template: '_shared/posts/templates/likes_modal'
    cancelEl: '#close'

    initialize: (options)->
      #Collection of likes
      @likes = options.likes

    templateHelpers: ->
      likes: @likes.models

    events: ->
      'click #js-request-friendship':'clickedRequest'
      'click #js-accept-friendship':'clickedAccept'
      'click #js-reject-friendship':'clickedReject'
      'click #js-delete-friendship':'clickedDelete'
      'click #js-cancel-friendship':'clickedCancel'

    updateView: ->
      view = @
      @likes.fetch
        success: ->
          view.render()

    currentModel: (e)->
      link = $(e.currentTarget)
      id = link.closest('div.userCardLike').data('id')
      @likes.get(id)

    clickedRequest: (e)->
      e.preventDefault()
      self = @
      model = @currentModel(e)
      attrs = attrs = { friend_id: model.get('user').id }
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      friendship.on 'save:success', (response, options) ->
        AlumNet.current_user.incrementCount('pending_sent_friendships')
        self.updateView()
      friendship.on 'save:error', (response, options)->
        console.log response.responseJSON

    clickedAccept: (e)->
      e.preventDefault()
      self = @
      model = @currentModel(e)
      attrs = model.get('user').friendship
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      friendship.on 'save:success', (response, options) ->
        AlumNet.current_user.decrementCount('pending_received_friendships')
        AlumNet.current_user.incrementCount('friends')
        self.updateView()
      friendship.on 'save:error', (response, options)->
        console.log response.responseJSON

    clickedReject: (e)->
      e.preventDefault()
      model = @currentModel(e)
      @destroyFriendship(model, 'pending_received_friendships')


    clickedDelete: (e)->
      e.preventDefault()
      model = @currentModel(e)
      @destroyFriendship(model, 'friends')


    clickedCancel: (e)->
      e.preventDefault()
      model = @currentModel(e)
      @destroyFriendship(model, 'pending_sent_friendships')


    destroyFriendship: (model, counter)->
      view = @
      attrs = model.get('user').friendship
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        view.updateView()
        AlumNet.current_user.decrementCount(counter)

