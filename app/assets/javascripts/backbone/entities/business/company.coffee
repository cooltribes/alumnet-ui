@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Company extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + "/companies"

    sizes: { 1: "1 - 10", 2: "11 - 50", 3: "51 - 200", 4: "201 - 500", 5: "501 - 1.000",
    6: "1.001 - 5.000", 7: "5.001 - 10.000", 8: "+10.001" }

    sizes_options: (select)->
      options = ""
      _.each @sizes, (value, key, list)->
        selected = if select == key then "selected" else ""
        options = options + "<option value='#{key}' #{selected}>#{value}</option>"
      options

    employees_count: ->
      @get('employees').length

    branches_count: ->
      @get('branches').length

    links_count: ->
      @get('links').length

    validation:
      name:
        required: true
      sector_id:
        required: true
      size:
        required: true

  class Entities.CompaniesCollection extends Backbone.Collection
    model: Entities.Company
    url: ->
      AlumNet.api_endpoint + "/companies"





