@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.CompanyAdmin extends Backbone.Model

  class Entities.CompanyAdminsCollection extends Backbone.Collection
    model: Entities.CompanyAdmin

  API =
    getNewCompanyAdminCollection: (company_id)->
      company_admins = new Entities.CompanyAdminsCollection
      company_admins.url = AlumNet.api_endpoint + "/companies/#{company_id}/company_admins"
      company_admins

    getNewCompanyAdmin: (company_id, attrs)->
      company_admins = new Entities.CompanyAdmin attrs
      company_admins.urlRoot = AlumNet.api_endpoint + "/companies/#{company_id}/company_admins"
      company_admins

  AlumNet.reqres.setHandler 'get:company_admins', (company_id)->
    API.getNewCompanyAdminCollection(company_id)

  AlumNet.reqres.setHandler 'new:company_admin', (company_id, attrs)->
    API.getNewCompanyAdmin(company_id, attrs)
