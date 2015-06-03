@AlumNet.module 'PagesApp.Programs', (Programs, @AlumNet, Backbone, Marionette, $, _) ->

  class Programs.Business extends Marionette.ItemView
    template: 'pages/programs/templates/business_exchange'

    initialize: ()->
      document.title='AlumNet - Business Exchange Program'

  class Programs.Home extends Marionette.ItemView
    template: 'pages/programs/templates/home_exchange'

    initialize: ()->
      document.title='AlumNet - Home Exchange Program'

  class Programs.Job extends Marionette.ItemView
    template: 'pages/programs/templates/job_exchange'

    initialize: ()->
      document.title='AlumNet - Jobs Exchange Program'

  class Programs.AGroups extends Marionette.ItemView
    template: 'pages/programs/templates/agroups'

    initialize: ()->
      document.title='AlumNet - A-Groups Program'

  class Programs.AlumNite extends Marionette.ItemView
    template: 'pages/programs/templates/alumnite'

    initialize: ()->
      document.title='AlumNet - ALUMnite Program'

  class Programs.MeetUps extends Marionette.ItemView
    template: 'pages/programs/templates/meetups'

    initialize: ()->
      document.title='AlumNet - Global Meet-ups Program'
