@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Profile extends Backbone.Model
    validation:
      first_name:
        required: true
      last_name:
        required: true
      gender:[
        {
          required: true
          msg: "Gender is required"          
        },
        {
          oneOf: ["F", "M"]
        }
      ]
        
      birth_country_id:[
        {
          required: true
          msg: "Country of origin is required"          
        }
      ]
      birth_city_id:[
        {
          required: true
          msg: "City of origin is required"          
        }
      ]
      residence_country_id:[
        {
          required: true
          msg: "Country of residence is required"          
        }
      ]
        
      residence_city_id:[
        {
          required: true
          msg: "City of residence is required"          
        }
      ]
        
      born: 'customValidation'

    customValidation: (value, attr, computedState)->
      if value == ''
        Backbone.Validation.validators.required(value, attr, true, @)
      else if moment().diff(moment(value), 'years') < 20
        'you must have more than 20 years'