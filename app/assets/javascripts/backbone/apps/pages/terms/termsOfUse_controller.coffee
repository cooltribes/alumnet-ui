@AlumNet.module 'PagesApp.Terms', (Terms, @AlumNet, Backbone, Marionette, $, _) ->
  class Terms.Controller
    showTermsOfUse: ->
      page = new Terms.View
      AlumNet.mainRegion.show(page)
      AlumNet.execute 'show:footer'




