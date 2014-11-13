@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.UserView extends Marionette.ItemView
    template: 'friends/find/templates/user'
    ui:
      request: "#request-button"
      requestLink: "#js-request-friendship"
    events:
      'click #js-request-friendship':'clickedRequest'
    clickedRequest: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'request'

    removeLink: ->
      @ui.requestLink.remove()
      @ui.request.append('<span>Request send</span>')

  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
    childViewContainer: ".users-list"
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm