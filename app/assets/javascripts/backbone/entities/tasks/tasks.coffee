@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Tasks extends Backbone.Model
  # EMPLOYMENT_TYPES = { 0 => "Full-time", 1 => "Part-time", 2 => "Internship", 3 => "Temporary"}
  # POSITION_TYPES = { 0 => "Top Management/Director", 1 => "Middle management", 2 => "Senior Specialist",
  #   3 => "Junior Specialist", 4 => "Entry job" }

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
