@AlumNet.module 'ErrorsApp', (ErrorsApp, @AlumNet, Backbone, Marionette, $, _) ->

  API =
    errorNotFound: ->
      controller = new ErrorsApp.NotFound.Controller
      controller.show()
    errorForbidden: ->
      controller = new ErrorsApp.Forbidden.Controller
      controller.show()

  AlumNet.on 'show:error', (status) ->
    switch status
      when 404
        API.errorNotFound()
      when 403
        API.errorForbidden()