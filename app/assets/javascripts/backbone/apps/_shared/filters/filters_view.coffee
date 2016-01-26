@AlumNet.module 'Shared.Views.Filters', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Row extends Marionette.ItemView
    template: '_shared/filters/templates/_row'

    modelEvents: 
      "change:active": "changeActive"
    
    bindings:
      "#text": "text"
      "#active": "active"

    changeActive: (m, v, options)->      
      if options.stickitChange      
        m.collection.trigger "checkStatus"

    onRender: ->
      @stickit()        


  class Filters.Layout extends Marionette.CompositeView
    template: '_shared/filters/templates/layout'
    childView: Filters.Row
    childViewContainer: '#rows-region'
    bindings:
      "#all_selected": 
        observe: "all_selected"
        getVal: ($el, event, options)->
          $el.val()

    ui:
      'selectCountries':'.js-countries'       

    modelEvents: 
      "change:all_selected": "changeAll"

    events:
      "click #all_selected": "clickAll"
      "select2-selecting @ui.selectCountries": "addCountry"


    initialize: (options)->    
      @results_collection = options.results_collection  
      @model = new Backbone.Model
        all_selected: true
      
      #Search for the initial cities and countries
      ###locations = [
        text: "Andorra la Vella"
        id: 1
        type: "city"
      , 
        text: "Balkh"
        id: 22
        type: "city"
      ]###
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


    clickAll: (e)->
      checkbox = $(e.currentTarget)
      if !checkbox.is(":checked")
        e.preventDefault()
        return false

      
    onRender: ->
      data = CountryList.toSelect2()      
      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: data
        formatResult: @formatSelect2
        formatSelection: @formatSelect2

      @stickit()  

   
    addCountry: (e)->
      country = _.extend
        active: true
        type: "country"
      ,
        e.choice        
      @collection.add country


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
        query:
          filtered:
            filter:
              bool:
                should: locationTerms
      
      querySearch = 
        type: "profile"          
        q: query

        
      @results_collection.search_by_filters(querySearch)  
        

    formatSelect2: (state)->
      return state.text + "nelson";
