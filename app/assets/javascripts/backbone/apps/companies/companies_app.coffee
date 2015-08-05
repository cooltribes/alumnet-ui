@AlumNet.module 'CompaniesApp', (CompaniesApp, @AlumNet, Backbone, Marionette, $, _) ->

  class CompaniesApp.Router extends AlumNet.Routers.Base
      appRoutes:
        "companies": "about"
        "companies/new": "createCompany"

        # "companies/discover": "discover"
        #"companies/:id/about": "about"


    API =
      about: ()->
        document.title = 'AlumNet - Companies'
        controller = new CompaniesApp.About.Controller
        controller.showAbout()

      createCompany: ->
        document.title = 'AlumNet - Companies'
        controller = new CompaniesApp.Create.Controller
        controller.create()

      # discover: ()->
      #   document.title = 'AlumNet - Companies'
      #   controller = new CompaniesApp.About.Controller
      #   controller.showAbout()


    AlumNet.on "companies", () ->
        AlumNet.navigate("companies")
        API.about()

    # AlumNet.on "companies/discover", () ->
    #     AlumNet.navigate("companies/discover")
    #     API.discover()


    AlumNet.addInitializer ->
      new CompaniesApp.Router
        controller: API
