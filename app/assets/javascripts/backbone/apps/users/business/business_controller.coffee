@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->
  class Business.Controller
    showBusiness: (id)->
      AlumNet.execute('render:users:submenu')
      
      user = AlumNet.request("user:find", id)
      
      user.on 'find:success', (response, options)=>

        layout = AlumNet.request("user:layout", user, 5)
        header = AlumNet.request "user:header", user

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)

      