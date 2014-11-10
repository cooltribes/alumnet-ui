@AlumNet.module 'UserApp.Friends', (Friends, @AlumNet, Backbone, Marionette, $, _) ->

  class Friends.User extends Marionette.ItemView
    template: 'user/friends/templates/user'
    tagName: 'li'
    ui:
      request: ".request-button"
      requestLink: "a.js-request-friendship"

    events:
      'click a.js-request-friendship':'clickedRequestFriendship'

    clickedRequestFriendship: (e)->
      e.preventDefault()
      @trigger 'request'

    removeLink: ->
      @ui.requestLink.remove()
      @ui.request.append('<span>Request send</span>')

  class Friends.Users extends Marionette.CompositeView
    template: 'user/friends/templates/users_container'
    childView: Friends.User
    childViewContainer: ".users-list"
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      $searchForm = this.$el.find('form#search-form')
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        email_cont: searchTerm
