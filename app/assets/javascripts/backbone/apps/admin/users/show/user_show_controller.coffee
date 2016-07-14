@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->
  class UserShow.Controller
    userShow: (id)->
      user = new AlumNet.Entities.AdminUser { id: id }
      user.urlRoot = AlumNet.api_endpoint + "/admin/users"
      user.fetch
        success: ->
          layout = new UserShow.Layout
            model: user
          overview = new UserShow.Overview
            model: user
          AlumNet.mainRegion.show(layout)
          layout.content.show(overview)
          AlumNet.execute('render:admin:users:submenu', undefined, 0)
          AlumNet.execute 'show:footer'

