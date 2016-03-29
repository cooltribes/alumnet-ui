@AlumNet.module 'JobExchangeApp', (JobExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange": "showJobExchangeHome"
      "job-exchange/discover": "discoverJobExchange"
      "job-exchange/my-posts": "myJobExchange"
      "job-exchange/applied": "appliedJobExchange"
      "job-exchange/automatches": "automatchesJobExchange"
      "job-exchange/invitations": "invitationsJobExchange"
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"
      "job-exchange/:id": "showJobExchange"

  API =
    discoverJobExchange: ->
      AlumNet.setTitle('Discover jobs')
      controller = new JobExchangeApp.Main.Controller
      controller.showMainLayout("discoverJobExchange")
    myJobExchange: ->
      AlumNet.setTitle('My jobs')
      controller = new JobExchangeApp.Main.Controller
      controller.showMainLayout("manageJobExchange")
    appliedJobExchange: ->
      AlumNet.setTitle('Applied jobs')
      controller = new JobExchangeApp.Main.Controller
      controller.showMainLayout("myApplications")
    automatchesJobExchange: ->
      AlumNet.setTitle('Automatches')
      controller = new JobExchangeApp.Main.Controller
      controller.showMainLayout("automatches")
    invitationsJobExchange: ->
      AlumNet.setTitle('Job invitations')
      controller = new JobExchangeApp.Invitations.Controller
      controller.invitations()
    createJobExchange: ->
      AlumNet.setTitle('Post a job')
      if AlumNet.current_user.get("profinda_api_token")
        controller = new JobExchangeApp.Create.Controller
        controller.create()
      else
        AlumNet.getProfindaApiToken()
    updateJobExchange: (id)->
      controller = new JobExchangeApp.Create.Controller
      controller.update(id)
    showJobExchange: (id)->
      controller = new JobExchangeApp.Show.Controller
      controller.show(id)
    showJobExchangeHome: (id)->
      controller = new JobExchangeApp.Main.Controller
      controller.showMainLayout()

  AlumNet.on "program:job:my", ->
    AlumNet.navigate("job-exchange/my-posts")
    API.myJobExchange()

  AlumNet.on "program:job:discover", ->
    AlumNet.navigate("job-exchange")
    API.discoverJobExchange()

  AlumNet.addInitializer ->
    new JobExchangeApp.Router
      controller: API