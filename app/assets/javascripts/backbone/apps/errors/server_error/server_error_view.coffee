@AlumNet.module 'ErrorsApp.ServerError', (ServerError, @AlumNet, Backbone, Marionette, $, _) ->

  class ServerError.View extends Marionette.ItemView
    template: 'errors/server_error/templates/server_error'
