@AlumNet.module 'Shared.Views.Filters.Profiles', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
    
  class Filters.PersonalContainer extends AlumNet.Shared.Views.Filters.Shared.FilterGroup   

    initialize: (options)->          
      ###@model = new Backbone.Model
        all_selected: true
        all_message: "All ages and gender"
        title: "Personal"###
      
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

      #Call parent constructor and pass options for the view model.
      super
        title: "Personal"    
        all_message: "All ages and gender"

      
    
    buildQuery: (active_rows = [])->
      personalFilters = [{}]

      gender = _.filter active_rows, (el)->
        el.get("type") == "gender"
      
      age_ranges = _.filter active_rows, (el)->
        el.get("type") == "age"
      
      if gender.length == 1 #because only one gender will affect the response, if both selected, is the same as no gender selected
        personalFilters.push
          query:
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


  class Filters.SkillLanguageContainer extends AlumNet.Shared.Views.Filters.Shared.FilterGroup
    ui:
      'select2':'.js-list' 
    
    events: ->
      events =
        "select2-selecting @ui.select2": "addRowFromSelect2"        
      _.extend super(), events         
    
    
    templateHelpers: ->      
      title: @settings.title


    initialize: (options)->   
      @type = options.type

      @settings = 
        endpoint_for_profile: "skills"
        title: "Skills"
      
      @collection = new AlumNet.Entities.SearchFiltersCollection
      
      @collection.on "add", (model) ->        
        @trigger("checkStatus")

      @collection.on "checkStatus", @checkStatus, @
      filterCollection = @collection
      
      #build the settings depending on what type of elements are being used [skills, lanaguages]
      if @type == "languages"        
        @settings.endpoint_for_profile = "language_levels" 
        @settings.title = "Languages"

      @preloaded_rows = new Backbone.Collection
      @preloaded_rows.url = AlumNet.api_endpoint + '/profiles/' + AlumNet.current_user.profile.id + "/#{@settings.endpoint_for_profile}"  
      @preloaded_rows.fetch
        success: (collection)->          
          #get only the first 4 elements          
          elements = collection.slice 0, 4
          filterCollection.reset(elements.map (item)->
            object = 
              value: item.id
              name: item.get("name")            

            if item.get("language_name")?
              object = 
                value: item.get "language_id"
                name: item.get("language_name")            

            object
          )

      #Call parent constructor and pass options for the view model.
      super
        title: @settings.title
        with_list: true    


    buildQuery: (active_rows = [])->
      ids_for_search = []
      query = {}
      
      if active_rows.length
        
        ids_for_search = active_rows.map (item)->
          item.get "value"

        search_term =   
          skill_ids: ids_for_search 

        if @type == "languages"     
          search_term =   
            language_ids: ids_for_search 

        query =         
          terms: search_term

      @trigger "search", query     


    onRender: ->
      @ui.select2.select2 @optionsForSelect2()       
      super()  


    optionsForSelect2: ()->        
      url = AlumNet.api_endpoint + "/#{@type}"      

      placeholder: "Select #{@settings.title}"            
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

        
    addRowFromSelect2: (e)->      
      new_row =         
        value: e.choice.id
        name: e.choice.text
        active: true

      @collection.add new_row


  class Filters.General extends AlumNet.Shared.Views.Filters.Shared.General
    template: '_shared/filters/profiles/templates/layout'
    regions:
      locations: "#locations"
      personal: "#personal"
      skills: "#skills"
      languages: "#languages"

    child_queries: [
      {}, {}, {}, {}
      ]

    initialize: (options)->      

      searchable_fields = ["name", "email"]
      type = "profile"
      @child_queries = [
        {}, {}, {}, {}
      ]
      
      super _.extend options,
        searchable_fields: searchable_fields
        type: type
      
      
    onRender: ->
      @locations_view = new AlumNet.Shared.Views.Filters.Shared.LocationContainer
        type: "profile"
        
      @personal_view = new Filters.PersonalContainer
      @skills_view = new Filters.SkillLanguageContainer
        type: "skills"

      @languages_view = new Filters.SkillLanguageContainer
        type: "languages"

      @locations_view.on "search", (filter)->
        @updateChildQueries(filter, 0)
      , @
      
      @personal_view.on "search", (filter)->
        @updateChildQueries(filter, 1)
      , @

      @skills_view.on "search", (filter)->
        @updateChildQueries(filter, 3)
      , @

      @languages_view.on "search", (filter)->
        @updateChildQueries(filter, 4)
      , @

      @locations.show(@locations_view)
      @personal.show(@personal_view)
      @skills.show(@skills_view)
      @languages.show(@languages_view)
      