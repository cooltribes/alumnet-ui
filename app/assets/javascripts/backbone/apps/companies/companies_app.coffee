@AlumNet.module 'CompaniesApp', (CompaniesApp, @AlumNet, Backbone, Marionette, $, _) ->

  class CompaniesApp.Router extends AlumNet.Routers.Base
      appRoutes:
        # "companies": "about"
        "companies": "discover"
        "companies/new": "createCompany"
        "companies/:id/about": "about"
        "companies/:id/employees": "employees"


    API =
      discover: ->
        document.title = 'AlumNet - Companies'
        controller = new CompaniesApp.Discover.Controller
        controller.discover()

      about: (id)->
        document.title = 'AlumNet - Companies'
        controller = new CompaniesApp.About.Controller
        controller.about(id)

      createCompany: ->
        document.title = 'AlumNet - Companies'
        controller = new CompaniesApp.Create.Controller
        controller.create()

      employees: (id)->
        document.title = 'AlumNet - Companies'
        controller = new CompaniesApp.Employees.Controller
        controller.employees(id)


    AlumNet.on "company:about", (id) ->
      AlumNet.navigate "companies/#{id}/about", 
        trigger: true
      # API.about(id)


    AlumNet.addInitializer ->
      new CompaniesApp.Router
        controller: API
