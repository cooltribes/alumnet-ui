@AlumNet.module 'FriendsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.FriendsView extends Marionette.LayoutView
    template: 'friends/main/templates/layout'
    
    regions:
      users_region: '#users-region'
      filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .optionMenuRight' : 'goOptionMenuRight'
      'click .js-search': 'performSearch'

    bindings:
      '#countApproval' : 'pending_approval_requests_count'
      '#countSent' : 'pending_sent_friendships_count'
      '#countReceived' : 'pending_received_friendships_count'
          
    templateHelpers: ->
      current_user = AlumNet.current_user
    
    onRender: ->
      @stickit()

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      searchId = click.attr('id').substring(3)
      @filter = searchId
      valueClick = click.attr("data-menu")
      @trigger "navigate:menu",valueClick
      @toggleLink(click)
      
    goOptionMenuRight: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menuRight",valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger 'friends:search', @buildQuerySearch(data.search_term, @filter), @users_region.currentView.collection, @filter
    
    buildQuerySearch: (searchTerm, filter) ->
      if filter == "sent"
        q:
          m: 'or'
          friend_profile_first_name_cont: searchTerm
          friend_profile_last_name_cont: searchTerm
          friend_email_cont: searchTerm
      else if filter == "received"
        q:
          m: 'or'
          user_profile_first_name_cont: searchTerm
          user_profile_last_name_cont: searchTerm
          user_email_cont: searchTerm
      else
        q:
          m: 'or'
          profile_first_name_cont: searchTerm
          profile_last_name_cont: searchTerm
          email_cont: searchTerm

