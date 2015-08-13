@AlumNet.module 'CompaniesApp.Employees', (Employees, @AlumNet, Backbone, Marionette, $, _) ->
  class Employees.Controller
    employees: (id)->
      company = new AlumNet.Entities.Company { id: id }
      company.fetch
        success: ->
          layout = AlumNet.request("company:layout", company, 0)
          header = AlumNet.request("company:header", company)

          employees = AlumNet.request("get:employees", company.id)

          employeesView = new Employees.List
            model: company
            collection: employees

          body = new Employees.Layout

          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(body)
          body.employees.show(employeesView)
          AlumNet.execute('render:companies:submenu',undefined, 1)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)
