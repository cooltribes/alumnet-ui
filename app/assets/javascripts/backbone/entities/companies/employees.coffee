@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Employee extends Backbone.Model

  class Entities.EmployeesCollection extends Backbone.Collection
    model: Entities.Employee

  API =
    getNewEmployeeCollection: (company_id, type)->
      employees = new Entities.EmployeesCollection
      employees.url = AlumNet.api_endpoint + "/companies/#{company_id}/#{type}"
      employees

  AlumNet.reqres.setHandler 'get:employees', (company_id)->
    API.getNewEmployeeCollection(company_id, 'employees')

  AlumNet.reqres.setHandler 'get:past_employees', (company_id)->
    API.getNewEmployeeCollection(company_id, 'past_employees')