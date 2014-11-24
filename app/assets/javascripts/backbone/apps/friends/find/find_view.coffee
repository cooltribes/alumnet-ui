@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.UserView extends Marionette.ItemView
    template: 'friends/find/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
    ui:
      linkContainer: '#link-container'
      requestLink: '#js-request-friendship'
      acceptLink: '#js-accept-friendship'
      deleteLink: '#js-delete-friendship'
    events:
      'click #js-request-friendship':'clickedRequest'
      'click #js-accept-friendship':'clickedAccept'
      'click #js-delete-friendship':'clickedDelete'

    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'

    clickedRequest: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'request'

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'delete'

    removeRequestLink: ->
      @ui.requestLink.remove()
      @ui.linkContainer.append('<span>Request send</span>')

    removeAcceptLink: ->
      @ui.acceptLink.remove()
      @ui.linkContainer.append('<span>Request Accept</span>')

  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
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