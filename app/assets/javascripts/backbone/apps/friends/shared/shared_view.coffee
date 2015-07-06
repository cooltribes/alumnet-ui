@AlumNet.module 'FriendsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  # class Shared.Header extends Marionette.ItemView
  #   template: 'friends/shared/templates/header'


  class Shared.Layout extends Marionette.LayoutView
    # template: 'friends/shared/templates/layout'

    getTemplate: ()->
      #whether to show layout for my friends or someones friends
      if @model.get("id") == AlumNet.current_user.get("id")
        'friends/shared/templates/myfriends_layout'
      else
        'friends/shared/templates/friends_layout'

    regions:
      body: '.friends-list'

    #for Stickit
    # bindings:
    #   "#js-approvalCount":
    #     observe: "pending_approval_requests_count"
    #     onGet: (value, options)->
    #       "Approval Requests (#{value})"


    initialize: (options) ->
      @listenTo(@model, 'change:pending_sent_friendships_count', @changedCountSent)
      @listenTo(@model, 'change:pending_received_friendships_count', @changedCountReceived)
      @listenTo(@model, 'change:friends_count', @changedCount)
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
    ui:
      'sendCount': '#js-sendCount'
      'receivedCount': '#js-receivedCount'

    events:
      'click .js-search': 'performSearch'
      'click #js-friends, #js-mutual, #js-myfriends, #js-sent, #js-received': 'showList'
      # 'click #js-approval': 'showApprovalList'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger 'friends:search', @buildQuerySearch(data.search_term), @body.currentView.collection

    showList: (e)->
      e.stopPropagation()
      e.preventDefault()
      actionId = $(e.currentTarget).attr('id').substring(3)
      @trigger "friends:show:#{actionId}", this
      @toggleLink(actionId)

    # showApprovalList: (e)->
    #   e.stopPropagation()
    #   e.preventDefault()
    #   id = $(e.currentTarget).attr('id').substring(3)
    #   @trigger "show:approval:requests", this
    #   @toggleLink(id)

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

    changedCountSent: ->
      messageSent = "Sent (#{@model.get('pending_sent_friendships_count')})"
      @ui.sendCount.html(messageSent)

    changedCountReceived: ->
      messageReceived = "Recieved (#{@model.get('pending_received_friendships_count')})"
      @ui.receivedCount.html(messageReceived)

    changedCount: ->
      console.log "here"
      message = "Friends (#{@model.get('friends_count')})"
      $(@ui.changedCount).html(message)

    onRender: ()->
      @stickit()

    bindings:
      "#js-receivedCount": "pending_received_friendships_count"  
      "#js-myFriendsCount":"friends_count"

  API =
    getFriendsLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    # getUserHeader: (model)->
    #   new Shared.Header
    #     model: model

  # AlumNet.reqres.setHandler 'user:header', (model)->
  #   API.getUserHeader(model)


  AlumNet.reqres.setHandler 'users:friends:layout', (model, tab) ->
    API.getFriendsLayout(model, tab)
