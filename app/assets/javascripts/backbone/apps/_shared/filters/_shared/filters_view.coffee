@AlumNet.module 'Shared.Views.Filters.Shared', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Row extends Marionette.ItemView
    template: '_shared/filters/_shared/templates/_row'

    modelEvents: 
      "change:active": "changeActive"
    
    bindings:
      "#name": "name"
      "#active": "active"

    changeActive: (m, v, options)->      
      if options.stickitChange      
        m.collection.trigger "checkStatus"

    onRender: ->
      @stickit()        


  class Filters.FilterGroup extends Marionette.CompositeView
    template: '_shared/filters/_shared/templates/filter_group'    
    childView: Filters.Row
    childViewContainer: '#rows-region'
    bindings:
      "#all_selected": 
        observe: "all_selected"
        getVal: ($el, event, options)->
          $el.val()

    modelEvents: 
      "change:all_selected": "changeAll"

    events: ->
      "click #all_selected": "clickAll"

    initialize: ->
      @model = new Backbone.Model
        all_selected: true
        all_message: "All"
        title: ""

    onRender: ->
      @stickit()  
      
       
    clickAll: (e)->
      checkbox = $(e.currentTarget)
      if !checkbox.is(":checked")
        e.preventDefault()
        return false

    
    changeAll: (m, v, options)->
      if options.stickitChange #if the change was triggered by clicking checkbox
        @collection.forEach (element, index)->
          element.set "active", false,
      
        @buildQuery() 


    checkStatus: () -> 
      active_locations = @collection.where
        active: true      
      
      # check/uncheck "All Locations"
      @model.set("all_selected", !(active_locations.length > 0)) #If there are at least one city/country selected
      @buildQuery(active_locations)


  class Filters.LocationContainer extends AlumNet.Shared.Views.Filters.Shared.FilterGroup   
    template: '_shared/filters/_shared/templates/locations'    
    ui:
      'selectCountries':'.js-countries' 
    
    events: ->
      events =
        "select2-selecting @ui.selectCountries": "addLocationFromSelect"        
      _.extend super(), events      
    
      
    onRender: ->
      @ui.selectCountries.select2 @optionsForSelect2()       

      super()  


    initialize: (options)->    
      @model = new Backbone.Model
        all_selected: true

      @type = options.type  #[profile, other] because the query is built in a different way for each type of model
      
      #Search for the initial cities and countries     
      locations = []

      current_user = AlumNet.current_user     

      res_country = _.extend
        type: "country"
      ,  
        current_user.profile.get "residence_country"
      
      res_city = _.extend
        type: "city"
      ,  
        current_user.profile.get "residence_city"

      locations.push(res_country, res_city)

      birth_country = _.extend
        type: "country"
      ,  
        current_user.profile.get "birth_country"
      
      birth_city = _.extend
        type: "city"
      ,  
        current_user.profile.get "birth_city"

      if birth_city.id != res_city.id  
        locations.push(birth_city)
      
      if birth_country.id != res_country.id  
        locations.push(birth_country)


      @collection = new AlumNet.Entities.SearchFiltersCollection locations

      #When a new location is added, trigger the search as if it was clicked
      @collection.on "add", (model) ->        
        @trigger("checkStatus")

      @collection.on "checkStatus", @checkStatus, @


    buildQuery: (active_locations = [])->
      
      locationTerms = []
      console.log "@type"
      console.log @type

      cities_array = _.filter active_locations, (el)->
        el.get("type") == "city"

      countries_array = _.filter active_locations, (el)->
        el.get("type") == "country"

      if cities_array.length > 0        
        cities_ids = _.pluck(cities_array, "id")                       

        if @type == "profile"
          terms = [
            terms:
              "residence_city_id": cities_ids
          ,
            terms:
              "birth_city_id": cities_ids
          ]
        else
          terms = [
            terms:
              "city_id": cities_ids        
          ]

        locationTerms.push terms
      
      if countries_array.length > 0        
        countries_ids = _.pluck(countries_array, "id")                       

        if @type == "profile"
          terms = [
            terms:
              "residence_country_id": countries_ids
          ,
            terms:
              "birth_country_id": countries_ids
          ]
        else
          terms = [
            terms:
              "country_id": countries_ids        
          ]

        locationTerms.push terms
      
      query =         
        bool:
          should: locationTerms 

      @trigger "search", query       
        

    addLocationFromSelect: (e)->      
      location = 
        id: e.choice.id
        name: e.choice.name
        active: true
        type: if e.choice.country then "city" else "country"

      @collection.add location
  
    
    optionsForSelect2: ()->  
      url = AlumNet.api_endpoint + '/countries/locations'      

      placeholder: "Select City or Country"      
      formatResult: @formatSelect2
      formatSelection: @formatSelect2
      minimumInputLength: 2
      ajax:
        url: url
        dataType: 'json'
        data: (term)->
          q: term
        results: (data, page) ->
          results:
            data

    
    formatSelect2: (data)->
      country = ""
      
      if data.country
        country = " <span class='country-select'> (" + data.country + ")</span>"
      
      return data.name + country    


  class Filters.General extends Marionette.LayoutView    
    className: "advancedFilters"
     
    initialize: (options)->    

      @searchable_fields = options.searchable_fields
      @type = options.type

      @results_collection = options.results_collection  
      @buildFilteredQuery()

    updateChildQueries: (query, index)->
      @child_queries[index] = query
      @search()

    search: ->
      @buildFilteredQuery()
      @results_collection.search_by_filters(@querySearch)

    buildFilteredQuery: ()->
      filtered = 
        filter:
          bool:
            must: @child_queries

      #the part with the search term to be combined with filters
      internal_query = @results_collection.getInternalQuery(@searchable_fields)
      if internal_query? then filtered.query = internal_query.query
      
      query =         
        query:
          filtered: filtered

      @querySearch = 
        type: @type          
        q: query                        