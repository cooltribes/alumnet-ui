@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    registration: (step)->
      

      layoutView = new Main.Layout
        step: step

      AlumNet.mainRegion.show(layoutView)


    activateUser: ->
      Backbone.ajax
        url: AlumNet.api_endpoint + "/me/activate"
        method: "post"
        success: (data)->
          if data.status == "active"
            AlumNet.current_user.fetch
              success: ->
                # if AlumNet.current_user.profile.get('role') == "External"
                #   AlumNet.headerRegion.reset()
                #   alert "Hola Externo!"
                # else
                #   AlumNet.headerRegion.reset()
                AlumNet.navigate("posts", { trigger: true })
          else
            $.growl.error { message: data.status }  

