@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.FriendsView extends Marionette.CompositeView
    template: 'friends/list/templates/friends_container'
    childView: AlumNet.FriendsApp.Find.UserView
    events:
      'click .js-search': 'performSearch'
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
      #console.log @ui.loading
      #@ui.loading.hide()
      $('.throbber-loader').hide()
      $(window).unbind('scroll')

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