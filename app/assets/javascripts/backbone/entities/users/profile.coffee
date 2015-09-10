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

      born:
        'customValidation'


    customValidation: (value, attr, computedState)->
      if value == ''
        Backbone.Validation.validators.required(value, attr, true, @)
        return 'Date of birth is required';

      else if moment().diff(moment(value), 'years') < 20
        'you must have more than 20 years'

    getDateBorn: ()->
      born = @get('born')
      if born
        day = ("0" + born.day).slice(-2)
        month = ("0" + born.month).slice(-2)
        "#{born.year}-#{month}-#{day}"