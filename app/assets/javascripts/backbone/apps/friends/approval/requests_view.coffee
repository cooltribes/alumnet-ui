@AlumNet.module 'FriendsApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->

  class Approval.EmptyView extends Marionette.ItemView
    template: 'friends/approval/templates/empty'

  class Approval.RequestView extends Marionette.ItemView
    template: 'friends/approval/templates/request'
    tagName: 'div'
    className: 'col-md-6 col-sm-6'
    events:
      'click #js-accept':'clickedAccept'
      'click #js-delete':'clickedDelete'

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'decline'

    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'

  class Approval.RequestsView extends Marionette.CompositeView
    template: 'friends/approval/templates/requests_container'
    childView: Approval.RequestView
    emptyView: Approval.EmptyView

    initialize: (options)->
      @parentView = options.parentView
      @query = options.query

      if @query
        @collection.fetch
          reset: true
          remove: true
          data: @query

      @on 'childview:accept', (childView)->
        self = @
        request = childView.model
        request.save {},
          success: ->
            self.collection.remove(request)
            AlumNet.current_user.decrementCount('pending_approval_requests')

      @on 'childview:decline', (childView)->
        request = childView.model
        request.destroy
          success: ->
            AlumNet.current_user.decrementCount('pending_approval_requests')

    ui:
      'loading': '.throbber-loader'

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')
      $(window).scroll(@loadMoreUsers)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreUsers: (e)->
      if @collection.nextPage == null
        endPagination()
      else
        if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
          @reloadItems()

    reloadItems: ->
      if @query
        @query.page = @collection.nextPage
        @collection.fetch
          reset: false
          remove: false
          data: @query