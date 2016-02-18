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
      '#countFriends':
        observe: 'friends_count'
        update: ($el, val)->
          if val > 0
            $el.show()
            $el.find("#countFriendsShow").html(val)
          else
            $el.hide()
            
      '#countApproval':
        observe: 'pending_approval_requests_count'
        update: ($el, val)->
          if val > 0
            $el.show()
            $el.find("#countApprovalShow").html(val)
          else
            $el.hide()

      '#countSent':
        observe: 'pending_sent_friendships_count'
        update: ($el, val)->
          if val > 0
            $el.show()
            $el.find("#countSentShow").html(val)
          else
            $el.hide()

      '#countReceived':
        observe: 'pending_received_friendships_count'
        update: ($el, val)->
          if val > 0
            $el.show()
            $el.find("#countReceivedShow").html(val)
          else
            $el.hide()

    initialize: (options)->
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      #console.log @tab
      if @tab == 0
        #console.log "entro"
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "myFriends"
          return 1
        when "friendsApproval"
          return 2
        when "friendsDiscover"
          return 0

    templateHelpers: ->
      @current_user = AlumNet.current_user
      classOf: (step) =>
        @class[step]

    onRender: ->
      @stickit()

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      searchId = click.attr('id').substring(3)
      @filter = searchId
      valueClick = click.attr("data-menu")
      if valueClick == "friendsDiscover"
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")
      @trigger "navigate:menu",valueClick
      @toggleLink(click)
      
    goOptionMenuRight: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menuRight",valueClick
      @toggleLinkRight(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    toggleLinkRight: (element)->
      $(".optionMenuRight").removeClass("submenu__item__link--active")
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
      else if filter == "received" || filter == "approval"
        q:
          m: 'or'
          user_profile_first_name_cont: searchTerm
          user_profile_last_name_cont: searchTerm
          user_email_cont: searchTerm
      else if filter == "myFriends"
        q:
          m: 'or'
          profile_first_name_cont: searchTerm
          profile_last_name_cont: searchTerm
          email_cont: searchTerm
      else
        searchTerm