@AlumNet.module 'CompaniesApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'company/shared/templates/header'

    
  class Shared.Layout extends Marionette.LayoutView
    template: 'company/shared/templates/layout'

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
    getCompanyLayout: (tab)->
      new Shared.Layout
        #model: model
        tab: tab

    getCompanyHeader: ()->
      #options = _.extend options, model: model
      new Shared.Header #options


  AlumNet.reqres.setHandler 'company:layout', (tab) ->
    API.getCompanyLayout(tab)

  AlumNet.reqres.setHandler 'company:header', ()->
    API.getCompanyHeader()