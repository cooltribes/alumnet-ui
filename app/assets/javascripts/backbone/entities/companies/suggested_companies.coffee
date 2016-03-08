@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.SuggestedCompaniesCollection extends Backbone.Collection
    model: Entities.Company
    url: ->
      AlumNet.api_endpoint + '/me/suggestions/companies/'
