@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Tasks extends Backbone.Model

    canApply: ->
      not @canDelete()

    canEdit: ->
      @canDelete()

    canDelete: ->
      @get('user').id == AlumNet.current_user.id

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Description is required, must be less than 2048 characters long"
      nice_have_list:
        required: true
      must_have_list:
        required: true

  class Entities.JobExchange extends Entities.Tasks
    urlRoot: ->
      AlumNet.api_endpoint + '/job_exchanges'

  class Entities.JobExchangeCollection extends Backbone.Collection
    model:
      Entities.JobExchange
    url: ->
      AlumNet.api_endpoint + '/job_exchanges'
