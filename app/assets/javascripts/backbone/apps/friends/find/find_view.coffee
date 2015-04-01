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
      'deleteLink': '#js-delete-friendship'
    events:
      'click #js-request-friendship':'clickedRequest'
      'click #js-accept-friendship':'clickedAccept'
      'click #js-delete-friendship':'clickedDelete'


    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'
      @model.fetch()
      

    clickedRequest: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'request'
      @model.fetch()

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
      @model.fetch()  

    removeRequestLink: ->
      @ui.linkContainer.empty().append('<span class="glyphicon glyphicon-time"></span>')
      @trigger 'deleteRequest'
      @model.fetch()

    removeAcceptLink: ->
      @ui.linkContainer.empty().append('<span class="glyphicon glyphicon-time"></span>')
      @trigger 'removeRequest'
      @model.fetch()

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