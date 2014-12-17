@AlumNet.module 'ErrorsApp', (ErrorsApp, @AlumNet, Backbone, Marionette, $, _) ->

  API =
    errorNotFound: ->
      controller = new ErrorsApp.NotFound.Controller
      controller.show()

  AlumNet.on 'show:error', (status) ->
    switch status
      when 404
        API.errorNotFound()