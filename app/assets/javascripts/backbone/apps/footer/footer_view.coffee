@AlumNet.module 'FooterApp.Footer', (Footer, @AlumNet, Backbone, Marionette, $, _) ->
  class Footer.Layout extends Marionette.CompositeView
    template: 'footer/templates/layout'

  API =
    showFooter: ->
      view = new Footer.Layout
      AlumNet.footerRegion.show(view)

  AlumNet.commands.setHandler 'show:footer', ->
    API.showFooter()