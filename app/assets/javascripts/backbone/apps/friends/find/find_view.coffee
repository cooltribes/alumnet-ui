@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.EmptyView extends Marionette.ItemView
    template: 'friends/find/templates/empty'

  class Find.UserView extends Marionette.ItemView
    template: 'friends/find/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
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
      @trigger 'accept'


    clickedRequest: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'request'

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
        self.destroy()

    clickedCancel: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('pending_sent_friendships')
        self.destroy()

    removeCancelLink: ->
      @ui.linkContainer.empty()
      @model.set("friendship_status","none")



  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
    emptyView: Find.EmptyView
    childViewContainer: '.users-list'
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm