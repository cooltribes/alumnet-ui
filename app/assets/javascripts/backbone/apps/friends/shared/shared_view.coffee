@AlumNet.module 'FriendsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  # class Shared.Header extends Marionette.ItemView
  #   template: 'friends/shared/templates/header'  


  class Shared.Layout extends Marionette.LayoutView
    template: 'friends/shared/templates/layout'

    regions:
      # header: '#user-header'
      body: '.friends-list'

    initialize: (options) ->      
      @tab = options.tab      
      @class = [
        "", "", ""
        "", ""
      ]  
      @class[parseInt(@tab)] = "--active"   

    templateHelpers: ->
      model = @model
      classOf: (step) =>
        @class[step]  
      
      friends: () ->
        model.fc

    events:
      'click .js-search': 'performSearch'
      'click #js-friends, #js-sent, #js-received': 'getList'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)      
      @trigger 'friends:search', @buildQuerySearch(data.search_term)      
    
    listFriends: (e) ->
      e.preventDefault()
      @trigger 'friends:show:friends', this
    
    listSent: (e) ->
      e.preventDefault()
      @trigger 'friends:show:sent', this
      
    listReceived: (e) ->
      e.preventDefault()
      @trigger 'friends:show:received', this

    getList: (e)->
      e.stopPropagation()
      e.preventDefault()      
      id = $(e.currentTarget).attr('id').substring(3)
      @trigger "friends:show:#{id}", this
      @toggleLink(id)
    
    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm    

    toggleLink: (id)->
      link = $("#js-#{id}")      
      this.$("[id^=js-]").removeClass("sortingMenu__item__link--active")
      link.addClass("sortingMenu__item__link--active")

  API =
    getFriendsLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    # getUserHeader: (model)->
    #   new Shared.Header
    #     model: model
        

  AlumNet.reqres.setHandler 'my:friends:layout', (model, tab) ->
    API.getFriendsLayout(model, tab)

  # AlumNet.reqres.setHandler 'user:header', (model)->
  #   API.getUserHeader(model)