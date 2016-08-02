@AlumNet.module 'Shared.Views.Filters.All', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/all/templates/layout'
    regions:
      locations: "#locations"     

    child_queries: [
      {}
      ]  

    initialize: (options)->      

      searchable_fields = null #this means search in all fields included in results collection -> entities/search
      type = "all"
      
      super _.extend options,
        searchable_fields: searchable_fields
        type: type                                        
      

    onRender: ->
      @locations_view = new AlumNet.Shared.Views.Filters.Shared.LocationContainer
        type: "all"
        
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @       
            
      @locations.show(@locations_view)
     