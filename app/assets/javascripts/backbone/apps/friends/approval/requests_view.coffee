@AlumNet.module 'FriendsApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Approval.EmptyView extends Marionette.ItemView
    template: 'friends/approval/templates/empty'    

  class Approval.RequestView extends Marionette.ItemView
    template: 'friends/approval/templates/request'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
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
      #$('.throbber-loader').hide()
      $(window).unbind('scroll')

    loadMoreUsers: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'friends:reload'