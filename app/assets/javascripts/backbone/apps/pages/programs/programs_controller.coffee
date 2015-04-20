@AlumNet.module 'PagesApp.Programs', (Programs, @AlumNet, Backbone, Marionette, $, _) ->
  class Programs.Controller
    showBusiness: ->
      page = new Programs.Business
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:pages:submenu')
    showHome: ->
      page = new Programs.Home
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:pages:submenu')
    showJob: ->
      page = new Programs.Job
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:pages:submenu')
    showMeetUps: ->
      page = new Programs.MeetUps
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:pages:submenu')
    showAGroups: ->
      page = new Programs.AGroups
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:pages:submenu')
    showAlumNite: ->
      page = new Programs.AlumNite
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:pages:submenu')
    