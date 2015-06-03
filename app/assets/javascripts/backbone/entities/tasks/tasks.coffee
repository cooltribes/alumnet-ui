@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Tasks extends Backbone.Model
    validation:
      name:
        required: true
        maxLength: 250
        msg: "Name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Description is required, must be less than 2048 characters long"

  class Entities.JobExchange extends Entities.Tasks
    urlRoot: ->
      AlumNet.api_endpoint + '/job_exchanges'

  class Entities.JobExchangeCollection extends Backbone.Collection
    model:
      Entities.JobExchange
    urlRoot: ->
      AlumNet.api_endpoint + '/job_exchanges'
