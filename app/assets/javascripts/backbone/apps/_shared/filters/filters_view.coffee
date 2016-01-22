@AlumNet.module 'Shared.Views.Filters', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Row extends Marionette.ItemView
    template: '_shared/filters/templates/_row'

    modelEvents: 
      "change:active": "changeActive"
    
    bindings:
      "#text": "text"
      "#active": "active"

    changeActive: (e)->      
      @trigger("change")  

    onRender: ->
      @stickit()        


  class Filters.Layout extends Marionette.CompositeView
    template: '_shared/filters/templates/layout'
    childView: Filters.Row
    childViewContainer: '#rows-region'
    bindings:
      "#all_selected": 
        observe: "all_selected"
        updateModel: (val, event, options)->
          console.log "value"
          console.log val
          val

    modelEvents: 
      "change:all_selected": "changeActive"

    initialize: (options)->    
      @results_collection = options.results_collection  
      @model = new Backbone.Model
        all_selected: true

      #Search for the initial cities
      locations = [
        text: "Andorra la Vella"
        id: 1
        type: "city"
      , 
        text: "Balkh"
        id: 22
        type: "city"
      ]

      @collection = new AlumNet.Entities.SearchFiltersCollection locations

      
    onRender: ->
      @stickit()  
   

    changeActive: (e)->      
      console.log e
      ###@collection.forEach (element, index)->
        element.set("active", false)
      ###

    onChildviewChange: (child_view) ->
      
      active_locations = @collection.where
        active: true

      console.log active_locations        

      locationTerms = []
      
      if active_locations.length > 0 #If there are at least one city/country selected

        #Uncheck "all"
        @model.set("all_selected", false)

        city_ids = _.pluck(active_locations, "id")
        locationTerms = [
          terms:
            "residence_city_id": city_ids
        ,
          terms:
            "birth_city_id": city_ids
        ]
      else
        #Check "all"
        @model.set("all_selected", true)


      query =         
        query:
          filtered:
            filter:
              bool:
                should: locationTerms
      
      querySearch = 
        type: "profile"          
        q: query

        
      @results_collection.search_by_filters(querySearch)  
                       

