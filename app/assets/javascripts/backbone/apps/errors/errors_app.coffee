@AlumNet.module 'ErrorsApp', (ErrorsApp, @AlumNet, Backbone, Marionette, $, _) ->

  API =
    errorNotFound: ->
      controller = new ErrorsApp.NotFound.Controller
      controller.show()
    errorForbidden: ->
      controller = new ErrorsApp.Forbidden.Controller
      controller.show()
    showBanned: ->
      controller = new ErrorsApp.Banned.Controller
      controller.show()
    serverError: ->
      controller = new ErrorsApp.ServerError.Controller
      controller.show()

  AlumNet.on 'show:error', (status) ->
    switch status
      when 404
        API.errorNotFound()
      when 403
        API.errorForbidden()
      when 500
        API.serverError()

  AlumNet.on 'show:banned', ->
    API.showBanned()