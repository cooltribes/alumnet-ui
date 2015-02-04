@AlumNet.module 'ErrorsApp.Forbidden', (Forbidden, @AlumNet, Backbone, Marionette, $, _) ->

  class Forbidden.View extends Marionette.ItemView
    template: 'errors/forbidden/templates/forbidden'

