@AlumNet.module 'PagesApp.Programs', (Programs, @AlumNet, Backbone, Marionette, $, _) ->

  class Programs.Business extends Marionette.ItemView
    template: 'pages/programs/templates/business_exchange'

  class Programs.Home extends Marionette.ItemView
    template: 'pages/programs/templates/home_exchange'

  class Programs.Job extends Marionette.ItemView
    template: 'pages/programs/templates/job_exchange'

  class Programs.AGroups extends Marionette.ItemView
    template: 'pages/programs/templates/agroups'

  class Programs.AlumNite extends Marionette.ItemView
    template: 'pages/programs/templates/alumnite'

  class Programs.MeetUps extends Marionette.ItemView
    template: 'pages/programs/templates/meetups'