@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.SearchResult extends Backbone.Model
  # defaults:
  #   first: false,
  #   language_id: "",
  #   level: 3,

  # validation:
  #   language_id:
  #     required: true
  #     msg: "You have to select a language"
  #   level:
  #     required: true
  #     range: [1, 5]

  class Entities.SearchResultCollection extends Backbone.Collection
    model: Entities.SearchResult
    search_term: ""
    url: ->
      AlumNet.api_endpoint + '/search/' + @search_term

    initialize: (models, options)->      
      @changeSearchTerm(options.search_term)

    changeSearchTerm: (search_term)->
      @search_term = search_term
