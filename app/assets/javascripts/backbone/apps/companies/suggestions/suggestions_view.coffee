@AlumNet.module 'CompaniesApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Companies extends Marionette.ItemView
    template: 'companies/suggestions/templates/_company'

    templateHelpers: ->
      console.log @model
      location: @model.getLocation()

  class Suggestions.CompaniesView extends Marionette.CompositeView
    template: 'companies/suggestions/templates/layout'
    childView: Suggestions.Companies
    childViewContainer: '.companies-container'

    childViewOptions: ->
      collection: @collection

    initialize: (options)->
      @optionsMenuLeft = options.optionMenuLeft
      @parentView = options.parentView
      @query = options.query

      @collection.fetch
        reset: true
        remove: true
        data: @query

      console.log @collection

    templateHelpers: ->
      showDiscover: @showButtonDiscover()

    showButtonDiscover: ->
      if @optionsMenuLeft == "discoverCompanies"
        showDiscover = true
      else
        showDiscover = false
