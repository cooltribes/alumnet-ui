@AlumNet.module 'FriendsApp.Friends', (Friends, @AlumNet, Backbone, Marionette, $, _) ->
  class Friends.EmptyView extends Marionette.ItemView
    template: 'friends/friends/templates/empty'  

  class Friends.FriendsView extends Marionette.CompositeView
    template: 'friends/friends/templates/friends'
    childView: AlumNet.FriendsApp.Find.UserView
    emptyView: Friends.EmptyView

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
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'friends:reload'

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (model)->
          view.render()