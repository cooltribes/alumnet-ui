@AlumNet.module 'Shared.Views.Filters.Companies', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Filters.Sector extends AlumNet.Shared.Views.Filters.Shared.FilterGroup
    template: '_shared/filters/companies/templates/sectors'
    
    ui:
      'selectList':'.js-list'

    events: ->
      events =
        "select2-selecting @ui.selectList": "addItemFromList"
      _.extend super(), events


    onRender: ->
      @ui.selectList.select2 @optionsForSelect2()
      super()


    initialize: (options)->
      @model = new Backbone.Model
        all_selected: true
        all_message: "All"
        title: "Sector"
      
      @collection = new AlumNet.Entities.SearchFiltersCollection @preloadItems()

      #When a new item is added, trigger the search as if it was clicked
      @collection.on "add", (model) ->
        @trigger("checkStatus")

      @collection.on "checkStatus", @checkStatus, @


    preloadItems: ()->
      #Search for the initial rows in the filter group
      @items = preloadedItems = []
      items = @items
      @preloaded_rows = new Backbone.Collection
      @preloaded_rows.url = AlumNet.api_endpoint + '/sectors'
      @preloaded_rows.fetch
        success: (collection)->          
          #get only the first 4 elements
          collection = collection.shuffle()          
          elements = collection.slice 0, 4
          preloadedItems = elements.map (item)->
            object = 
              value: item.id
              name: item.get("name")      

        async: false             

      preloadedItems  


    buildQuery: (active_rows = [])->

      ids_for_search = []
      query = {}
      
      if active_rows.length               
        ids_for_search = active_rows.map (item)->
          item.get "value"        
        query =         
          terms:
            sector_id: ids_for_search

      @trigger "search", query     

     
    addItemFromList: (e)->
      item =
        value: e.choice.id
        name: e.choice.text
        active: true        

      @collection.add item


    optionsForSelect2: ()->
      url = AlumNet.api_endpoint + '/sectors'

      placeholder: "Add sector"            
      minimumInputLength: 2
      ajax:
        url: url
        dataType: 'json'
        data: (term)->
          q: 
            name_cont: term
        results: (data, page) ->
          results: data.map (item) ->            
            id: item.id
            text: item.name           


  class Filters.Size extends AlumNet.Shared.Views.Filters.Shared.FilterGroup 
    initialize: (options)->          
      @model = new Backbone.Model
        all_selected: true
        title: "Size"
        all_message: "All"
            
      @collection = new AlumNet.Entities.SearchFiltersCollection @preloadItems()   

      @collection.on "checkStatus", @checkStatus, @
       
    preloadItems: ()->
      #Search for the initial rows in the filter group
      company = new AlumNet.Entities.Company
          
      company.sizes.map (item)->
        object = 
          value: item.value
          name: item.text

    buildQuery: (active_rows = [])->
      query = {}           

      if active_rows.length             
        query =         
          terms:
            size: active_rows.map (item)->
              item.get "value"

      @trigger "search", query  


  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/companies/templates/layout'
    regions:
      locations: "#locations"
      sectors: "#sectors"
      size: "#size"

    child_queries: [{}]  

    initialize: (options)->      

      searchable_fields = ["name", "description"]
      type = "companies"
      
      super _.extend options,
        searchable_fields: searchable_fields
        type: type                                        
      

    onRender: ->
      @locations_view = new AlumNet.Shared.Views.Filters.Shared.LocationContainer
        type: "other"

      @sectors_view = new Filters.Sector
      @size_view = new Filters.Size
      
      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @   
      @sectors_view.on "search", (filter)->
        @updateChildQueries(filter, 1)
      , @ 
      @size_view.on "search", (filter)->
        @updateChildQueries(filter, 2)
      , @        
      
      @locations.show(@locations_view)
      @sectors.show(@sectors_view)
      @size.show(@size_view)
      