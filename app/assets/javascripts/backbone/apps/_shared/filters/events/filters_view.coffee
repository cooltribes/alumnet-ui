@AlumNet.module 'Shared.Views.Filters.Events', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/events/templates/layout'
    regions:
      locations: "#locations"

    child_queries: [
      {}
      ]  

    initialize: (options)->      

      searchable_fields = ["name", "description"]
      type = "events"
      
      super _.extend options,
        searchable_fields: searchable_fields
        type: type                                        
      

    onRender: ->
      @locations_view = new AlumNet.Shared.Views.Filters.Shared.LocationContainer
        type: "other"
      
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      
      @locations.show(@locations_view)
      