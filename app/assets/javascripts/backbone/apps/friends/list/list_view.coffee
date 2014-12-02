@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.FriendView extends Marionette.ItemView
    template: 'friends/list/templates/friend'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'

  class List.FriendsView extends Marionette.CompositeView
    template: 'friends/list/templates/friends_container'
    childView: List.FriendView
    childViewContainer: '.friends-list'
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger 'friends:search', @buildQuerySearch(data.search_term)

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm