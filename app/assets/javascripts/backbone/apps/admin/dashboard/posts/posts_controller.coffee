@AlumNet.module 'AdminApp.Dashboard.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->

  class Posts.Controller extends AlumNet.Controllers.Base

    initialize: ->

      AlumNet.execute('render:admin:dashboard:submenu', undefined, 1)

      layout = new Posts.Layout
      AlumNet.mainRegion.show(layout)