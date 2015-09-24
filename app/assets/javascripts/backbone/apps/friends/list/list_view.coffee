@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  # class List.FriendView extends Marionette.ItemView
  #   template: 'friends/find/templates/user'
  #   tagName: 'div'
  #   className: 'col-md-4 col-sm-6'

  class List.FriendsView extends Marionette.CompositeView
    template: 'friends/list/templates/friends_container'
    childView: AlumNet.FriendsApp.Find.UserView
    # childViewContainer: '.friends-list'
    events:
      'click .js-search': 'performSearch'
    
    initialize: (options)->
      console.log @collection
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')
      $(window).scroll(@loadMoreUsers)

    loadMoreUsers: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'friends:reload'
        
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

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (model)->
          view.render()
          console.log "success"