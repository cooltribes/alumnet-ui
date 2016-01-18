@AlumNet.module 'ErrorsApp', (ErrorsApp, @AlumNet, Backbone, Marionette, $, _) ->

  API =
    errorNotFound: ->
      AlumNet.setTitle('Page not found')
      controller = new ErrorsApp.NotFound.Controller
      controller.show()
    errorForbidden: ->
      AlumNet.setTitle('Forbidden accesst')
      controller = new ErrorsApp.Forbidden.Controller
      controller.show()
    showBanned: ->
      AlumNet.setTitle('Banned')
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