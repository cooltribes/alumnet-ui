@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Service extends Backbone.Model
    urlRoot: ->
      company_id = @get('company_id')
      if company_id
        AlumNet.api_endpoint + "/companies/#{company_id}/product_services"
      else
        null

    validation:
      name:
        required: true

  class Entities.ServicesCollection extends Backbone.Collection
    model: Entities.Service



