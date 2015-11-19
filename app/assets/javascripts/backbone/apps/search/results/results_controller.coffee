@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->

  class Results.Controller
    show: ->
      console.log "entroalaction"
      controller = @
      controller.querySearch = {}
      
      layoutView = @_getLayoutView()
      
      AlumNet.mainRegion.show(layoutView)

      ###layoutView.header_region.show(searchView)

      layoutView.list_region.show(groupsView)###

      
    #For internal use
    _getLayoutView: ->
      view = new Results.Layout

     ### view.on "search", @_applySearch, @
      view.on "advancedSearch", @_applyAdvancedSearch, @
      view.on "changeGrid", @_changeGrid, @
###