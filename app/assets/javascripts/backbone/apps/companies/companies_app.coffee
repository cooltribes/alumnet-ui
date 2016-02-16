@AlumNet.module 'CompaniesApp', (CompaniesApp, @AlumNet, Backbone, Marionette, $, _) ->

  class CompaniesApp.Router extends AlumNet.Routers.Base
      appRoutes:
        #"companies": "about"
        "companies/discover": "discover"
        "my-companies": "myCompanies"
        "companies/new": "createCompany"
        "companies/:id/about": "about"
        "companies/:id/employees": "employees"
        "companies/:id/job_posts": "jobPosts"


    API =
      discover: ->
        AlumNet.setTitle('Companies')
        controller = new CompaniesApp.Main.Controller
        controller.showMainCompanies("discoverCompanies")
      
      myCompanies: ->
        AlumNet.setTitle('My Companies')
        controller = new CompaniesApp.Main.Controller
        controller.showMainCompanies("myCompanies")

      about: (id)->
        AlumNet.setTitle('Companies')
        controller = new CompaniesApp.About.Controller
        controller.about(id)

      createCompany: ->
        AlumNet.setTitle('Create a Company')
        controller = new CompaniesApp.Create.Controller
        controller.create()

      employees: (id)->
        AlumNet.setTitle('Companies')
        controller = new CompaniesApp.Employees.Controller
        controller.employees(id)

      jobPosts: (id)->
        AlumNet.setTitle('Create New Companies')
        controller = new CompaniesApp.JobPosts.Controller
        controller.job_posts(id)

    AlumNet.on "company:about", (id) ->
      AlumNet.navigate "companies/#{id}/about",
        trigger: true
      # API.about(id)


    AlumNet.addInitializer ->
      new CompaniesApp.Router
        controller: API
