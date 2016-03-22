@AlumNet.module 'CompaniesApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Companies extends Marionette.ItemView
    template: 'companies/main/templates/_company_suggested'

    templateHelpers: ->
      location: @model.getLocation()

  class Suggestions.CompaniesView extends Marionette.CompositeView
    template: 'companies/main/templates/suggestions_container'
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

    templateHelpers: ->
      showDiscover: @showButtonDiscover()

    showButtonDiscover: ->
      if @optionsMenuLeft == "discoverCompanies"
        showDiscover = true
      else
        showDiscover = false
