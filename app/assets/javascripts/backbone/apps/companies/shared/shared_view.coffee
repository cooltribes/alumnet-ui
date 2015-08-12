@AlumNet.module 'CompaniesApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'companies/shared/templates/header'

  class Shared.Layout extends Marionette.LayoutView
    template: 'companies/shared/templates/layout'

    regions:
      header: '#company-header'
      body: '#company-body'

    initialize: (options) ->
      @tab = options.tab
      @class = ["", "", ""
        "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

  API =
    getCompanyLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    getCompanyHeader: (model)->
      new Shared.Header
        model: model


  AlumNet.reqres.setHandler 'company:layout', (model, tab) ->
    API.getCompanyLayout(model, tab)

  AlumNet.reqres.setHandler 'company:header', (model)->
    API.getCompanyHeader(model)