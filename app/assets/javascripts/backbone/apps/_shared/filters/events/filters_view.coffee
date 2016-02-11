@AlumNet.module 'Shared.Views.Filters.Events', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.LocationContainer extends AlumNet.Shared.Views.Filters.Shared.LocationContainer           
    buildQuery: (active_locations = [])->
      
      locationTerms = []

      cities_array = _.filter active_locations, (el)->
        el.get("type") == "city"

      countries_array = _.filter active_locations, (el)->
        el.get("type") == "country"

      if cities_array.length > 0        
        city_ids = _.pluck(cities_array, "id")                       

        locationTerms.push [
          terms:
            "city_id": city_ids        
        ]
      
      if countries_array.length > 0        
        countries_ids = _.pluck(countries_array, "id")                       

        locationTerms.push [
          terms:
            "country_id": countries_ids       
        ]
      
      query =         
        bool:
          should: locationTerms 

      @trigger "search", query       

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
      @locations_view = new Filters.LocationContainer
      
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      
      @locations.show(@locations_view)
      