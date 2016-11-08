@AlumNet.module 'FriendsApp.Requests', (Requests, @AlumNet, Backbone, Marionette, $, _) ->
  class Requests.EmptyView extends Marionette.ItemView
    template: 'friends/requests/templates/empty'

  class Requests.RequestView extends Marionette.ItemView
    template: 'friends/requests/templates/request'
    tagName: 'div'
    className: 'col-md-6 col-sm-6'
    events:
      'click #js-accept-friendship':'clickedAccept'
      'click #js-delete-friendship':'clickedDelete'

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'delete'

    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'


  class Requests.RequestsView extends Marionette.CompositeView
    template: 'friends/requests/templates/requests_container'
    emptyView: Requests.EmptyView
    childView: Requests.RequestView

    initialize: (options)->
      @parentView = options.parentView
      @query = options.query
      @friendship_type = options.friendship_type

      if @query
        @collection.fetch
          reset: true
          remove: true
          data: @query

      if @friendship_type == "received"
        @on 'childview:accept', (childView)->
          self = @
          friendship = childView.model
          friendship.save {},
            success: ->
              self.collection.remove(friendship)
              AlumNet.current_user.decrementCount('pending_received_friendships')
              AlumNet.current_user.incrementCount('friends')
              $.growl.notice({ message: "Invitation accepted" })

        @on 'childview:delete', (childView)->
          self = @
          friendship = childView.model
          friendship.destroy
            success: ->
              self.collection.remove(friendship)
              AlumNet.current_user.decrementCount('pending_received_friendships')
              $.growl.notice({ message: "Declined invitation" })

      if @friendship_type == "sent"
        @on 'childview:delete', (childView)->
          self = @
          friendship = childView.model
          friendship.destroy
            success: ->
              self.collection.remove(friendship)
              AlumNet.current_user.decrementCount('pending_sent_friendships')

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')
      $(window).scroll(@loadMoreUsers)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      $('.throbber-loader').hide()
      $(window).unbind('scroll')

    loadMoreUsers: (e)->
      if @collection.nextPage == null
        @endPagination()
      else
        if $(window).scrollTop()!=0 && ($(window).scrollTop() / ($(document).height() - $(window).height() )) > 0.97 
          @reloadItems()

    reloadItems: ->
      if @query
        @query.page = @collection.nextPage
        @collection.fetch
          remove: false
          reset: false
          data: @query