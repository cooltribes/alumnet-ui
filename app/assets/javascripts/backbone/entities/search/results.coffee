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
        when "task"
          null

    getUrl: ->
      AlumNet.buildUrlFromModel(@) #method implemented in libs/helpers                

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

      if @source.sector then @source.sector.name else null

    ## ------- Functions only for events
    isEvent: ->
      @getType() == "event"
         
    getEventStart: ->
      return null if !@isEvent()
      
      moment(@source.start_date).format('DD/MM/YYYY') + ", " + @source.start_hour

  
  class Entities.SearchResultCollection extends Backbone.Collection
    model: Entities.SearchResult
    search_term: ""        
    url: ->
      AlumNet.api_endpoint + '/search'

    initialize: (models, options)->
      @changeSearchTerm(options.search_term)

    changeSearchTerm: (search_term)->
      @search_term = search_term

    search: (type = "all")->
      ###@fetch(
        data: 
          term: @search_term
          type: @type
      )###

      query = 
        type: type

      if @getInternalQuery(@search_term)?
        query.q = @getInternalQuery(@search_term)
      else
        query.q = {}
        

      @search_by_filters(query)

    
    search_by_filters: (query)->
      @fetch
        data: JSON.stringify(query)
        type: "POST"           
        contentType: "application/json"

    getInternalQuery: (term, fields = null)->
      if fields?
        fields_for_search = fields
      else
        fields_for_search = ["name", "description", "short_description", "email"]

      if term != ""
        query:
          multi_match:
            query: term
            fields: fields_for_search
      else
        null