@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Profile extends Backbone.Model
    validation:
      first_name:
        required: true
      last_name:
        required: true
      gender:
        required: true
        oneOf: ["F", "M"]
      birth_country:
        required: true
      birth_city:
        required: true
      residence_country:
        required: true
      residence_city:
        required: true
      born: 'customValidation'

    customValidation: (value, attr, computedState)->
      if value == ''
        Backbone.Validation.validators.required(value, attr, true, @)
      else if moment().diff(moment(value), 'years') < 20
        'you must have more than 20 years'