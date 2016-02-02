@AlumNet.module 'Shared.Views.Filters', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Row extends Marionette.ItemView
    template: '_shared/filters/templates/_row'

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
    childView: Filters.Row
    childViewContainer: '#rows-region'
    bindings:
      "#all_selected": 
        observe: "all_selected"
        getVal: ($el, event, options)->
          $el.val()

    modelEvents: 
      "change:all_selected": "changeAll"

    
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
        

  class Filters.LocationContainer extends Filters.FilterGroup   
    template: '_shared/filters/templates/locations'    
    ui:
      'selectCountries':'.js-countries'       

    events:
      "click #all_selected": "clickAll"
      "select2-selecting @ui.selectCountries": "addLocationFromSelect"


    initialize: (options)->    
      @model = new Backbone.Model
        all_selected: true
      
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

      
    onRender: ->
      data = CountryList.toSelect2()      
      @ui.selectCountries.select2 @optionsForSelect2()       

      @stickit()  

   
    addLocationFromSelect: (e)->      
      location = 
        id: e.choice.id
        name: e.choice.name
        active: true
        type: if e.choice.country then "city" else "country"

      @collection.add location
  
       
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
            "residence_city_id": city_ids
        ,
          terms:
            "birth_city_id": city_ids
        ]
      
      if countries_array.length > 0        
        countries_ids = _.pluck(countries_array, "id")                       

        locationTerms.push [
          terms:
            "residence_country_id": countries_ids
        ,
          terms:
            "birth_country_id": countries_ids
        ]
      
      query =         
        bool:
          should: locationTerms 

      @trigger "search", query     
       

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


  class Filters.PersonalContainer extends Filters.FilterGroup 
    template: '_shared/filters/templates/personal'    
    events:
      "click #all_selected": "clickAll"     


    initialize: (options)->          
      @model = new Backbone.Model
        all_selected: true
      
      #Search for the initial cities and countries      
      ###,
        name: "Age under 26"
        type: "age"
        value: "-26"###
      filters = [
        name: "Female"
        type: "gender"
        value: "F"
      ,
        name: "Male"
        type: "gender"               
        value: "M"
      ,
        name: "Age 26-35's"
        type: "age"
        value: "26-35"
      ,
        name: "Age 36-45's"
        type: "age"
        value: "36-45"
      ,
        name: "Age 46-55's"
        type: "age"
        value: "46-55"
      ,
        name: "Age 56-65's"
        type: "age"
        value: "56-65"
      ]
      ###,
      name: "Age above 65"
      type: "age"
      value: "65-"###

      @collection = new AlumNet.Entities.SearchFiltersCollection filters     

      @collection.on "checkStatus", @checkStatus, @

      
    onRender: ->
      @stickit()  
      
       
    buildQuery: (active_locations = [])->
      personalFilters = []

      gender = _.filter active_locations, (el)->
        el.get("type") == "gender"
      
      age_ranges = _.filter active_locations, (el)->
        el.get("type") == "age"
      
      if gender.length == 1 #because only one gender will affect the response, both is the same as no gender filter
        personalFilters.push
          match:
            gender: gender[0].get("value")
      
      if age_ranges.length > 0                 
        ranges = []
        _.each age_ranges, (model, i)->           
          bounds = model.get("value").split("-")         
          ranges.push
            range:
              age: 
                gte: bounds[0]
                lte: bounds[1]

        personalFilters.push
          bool:
            should: ranges

      query =         
        bool:
          must: personalFilters

      @trigger "search", query     


  class Filters.SkillsContainer extends Filters.FilterGroup
    template: '_shared/filters/templates/skills'    
    events:
      "click #all_selected": "clickAll"


    initialize: (options)->    
      @model = new Backbone.Model
        all_selected: true  

      @collection = new AlumNet.Entities.SearchFiltersCollection

      #When a new location is added, trigger the search as if it was clicked
      @collection.on "add", (model) ->        
        @trigger("checkStatus")

      @collection.on "checkStatus", @checkStatus, @
      collection = @collection
      @skills = new AlumNet.Entities.Skills
      @skills.url = AlumNet.api_endpoint + '/profiles/' + AlumNet.current_user.profile.id + "/skills"  
      @skills.fetch
        success: (collection)->
          #slice this collection






      


  class Filters.General extends Marionette.LayoutView
    template: '_shared/filters/templates/layout'
    regions:
      locations: "#locations"
      personal: "#personal"
      skills: "#skills"
    className: "advancedFilters"

    child_queries: [
      {}, {}, {}
      ]  

    initialize: (options)->      
      @results_collection = options.results_collection  
      query =         
        query:
          filtered:
            filter:
              bool:
                must: @child_queries                
      
      ###query: #the part with the search term to be combined with filters
        multi_match:
          query: @results_collection.search_term
          fields: ["name", "email"]###

      @querySearch = 
        type: "profile"          
        q: query                        
      

    onRender: ->
      @locations_view = new Filters.LocationContainer
      @personal_view = new Filters.PersonalContainer
      @skills_view = new Filters.SkillsContainer

      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @  
      
      @personal_view.on "search", (filter)->
        @updateChildQueries(filter, 1)
      , @ 

      @skills_view.on "search", (filter)->
        @updateChildQueries(filter, 3)
      , @  

      @locations.show(@locations_view)
      @personal.show(@personal_view)
      @skills.show(@skills_view)


    updateChildQueries: (query, index)->
      @child_queries[index] = query
      @search()


    search: ->              
      @results_collection.search_by_filters(@querySearch)
