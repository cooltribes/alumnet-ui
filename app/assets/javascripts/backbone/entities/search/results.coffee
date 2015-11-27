@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.SearchResult extends Backbone.Model
    initialize: ->
      @source = @get "_source"      

    getImage: ->
      switch @get "_type"
        when "profile"
          @source.avatar.medium.url
        when "group", "event"
          @source.cover.main.url
        when "company"
          @source.logo.main.url
          ###when "event"
          @source.logo.main.url
          ### 
        when "task"
          null

    getTitle: ->
      @source.name    

    getType: ->
      # _.capitalize(@get("_type"))
      @get("_type")

    getLocation: ->
      switch @get "_type"
        when "profile"
          AlumNet.parseLocation("user", @source, true) #method implemented in libs/helpers          
        when "group", "event", "task"
          AlumNet.parseLocation("group", @source, true) #method implemented in libs/helpers                    
        when "company"
          AlumNet.parseLocation("company", @source, true) #method implemented in libs/helpers                              
          ###when "event"
          @source.logo.main.url
          ### 
        
    getDescription: ->
      description = null
      switch @get "_type"
        when "group", "event", "task", "company"
          description = @source.description        

      description    

    ## ------- Functions only for profiles
    isUser: ->
      @getType() == "profile"

    getPosition: ->
      return null if !@isUser()
      
      if @source.professional_headline
        @source.professional_headline
      else if @source.current_experience
        @source.current_experience.name
      else
        "No Position"
  
    ## ------- Functions only for companies
    isCompany: ->
      @getType() == "company"
         
    getIndustry: ->
      return null if !@isCompany()

      @source.sector.name




  
  class Entities.SearchResultCollection extends Backbone.Collection
    model: Entities.SearchResult
    search_term: ""
    url: ->
      AlumNet.api_endpoint + '/search?term=' + @search_term

    initialize: (models, options)->      
      @changeSearchTerm(options.search_term)

    changeSearchTerm: (search_term)->
      @search_term = search_term
