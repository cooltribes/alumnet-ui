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

    getImageClass: ->
      switch @get "_type"
        when "profile", "company"
          "img-circle avatarsize"
        when "group", "event"
          "img-circle searchResultImg"
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
        when "event", "task", "company"
          description = @source.description
        when "group"
          description = @source.short_description
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

    initialize: (options)->
      @lastQuery = null
      @per_page = 10
      @default_search_settings =
        page: 1
        remove: false
        reset: false
        type: "all"

    url: ->
      AlumNet.api_endpoint + '/search'

    setSearchSettings: (options)->
      @settings = _.extend(@default_search_settings, options)

    search: (search_term = "", options = {})->
      @search_term = search_term
      @setSearchSettings(options)

      query =
        type: @type

      internal_query = @getInternalQuery()
      if internal_query? then query.q = internal_query else query.q = {}

      @fetchData(query)

    search_by_type: (type = 'all')->
      @type = type
      @search(@search_term)

    search_by_filters: (query = "", options = {})->
      @search_by_query(query, options)

    search_by_query: (query = {}, options = {})->
      @setSearchSettings(options)
      @fetchData(query)

    search_by_last_query: (options = {})->
      @setSearchSettings(options)
      if @lastQuery == undefined
        @lastQuery = @getInternalQuery()
      else
        @fetchData(@lastQuery)

    fetchData: (query)->
      query.per_page = @per_page
      query.page = @settings.page
      @lastQuery = query
      @fetch
        reset: @settings.reset
        remove: @settings.remove
        data: JSON.stringify(query)
        type: "POST"
        contentType: "application/json"

    getInternalQuery: (fields = null)->
      if fields?
        fields_for_search = fields
      else
        fields_for_search = ["name", "description", "short_description", "email"]

      if @search_term != ""
        query:
          multi_match:
            query: @search_term
            fields: fields_for_search
      else
        null

    getCurrentPage: ->
      @settings.page

  API =

    usersResultsCollection: ->
      collection = new AlumNet.Entities.SearchResultCollection null,
        type: 'profile'
      collection.model = AlumNet.Entities.User
      collection.per_page = 5
      collection.url = AlumNet.api_endpoint + '/users/search'
      collection

    groupsResultsCollection: ->
      collection = new AlumNet.Entities.SearchResultCollection null,
        type: 'group'
      collection.model = AlumNet.Entities.Group
      collection.per_page = 5
      collection.url = AlumNet.api_endpoint + '/groups/search'
      collection

    eventsResultsCollection: ->
      collection = new AlumNet.Entities.SearchResultCollection null,
        type: 'event'
      collection.model = AlumNet.Entities.Event
      collection.per_page = 5
      collection.url = AlumNet.api_endpoint + '/events/search'
      collection

    companiesResultsCollection: ->
      collection = new AlumNet.Entities.SearchResultCollection null,
        type: 'company'
      collection.model = AlumNet.Entities.Company
      collection.per_page = 5
      collection.url = AlumNet.api_endpoint + '/companies/search'
      collection

  AlumNet.reqres.setHandler 'results:users', ->
    API.usersResultsCollection()

  AlumNet.reqres.setHandler 'results:groups', ->
    API.groupsResultsCollection()

  AlumNet.reqres.setHandler 'results:events', ->
    API.eventsResultsCollection()

  AlumNet.reqres.setHandler 'results:companies', ->
    API.companiesResultsCollection()