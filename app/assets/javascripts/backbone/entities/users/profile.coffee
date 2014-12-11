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
      birth_country_id:
        required: true
      birth_city_id:
        required: true
      residence_country_id:
        required: true
      residence_city_id:
        required: true
      born: 'customValidation'

    customValidation: (value, attr, computedState)->
      if value == ''
        Backbone.Validation.validators.required(value, attr, true, @)
      else if moment().diff(moment(value), 'years') < 20
        'you must have more than 20 years'