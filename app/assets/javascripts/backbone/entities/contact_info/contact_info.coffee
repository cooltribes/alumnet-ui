@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.ProfileContact extends Backbone.Model

    defaults:
      showDelete: true

    validation:
      contact_type:
        required: true
      info: 'customValidation'
      privacy:
        required: true

    customValidation: (value, attr, computedState)->
      contact_type = @get('contact_type')
      if contact_type == '0'
        Backbone.Validation.validators.pattern(value, attr, 'email', @)
      else if contact_type == '1'
        Backbone.Validation.validators.pattern(value, attr, 'number', @)
      else
        Backbone.Validation.validators.required(value, attr, true, @)

    contactTypes:
      0: 'Email'
      1: 'Phone'
      2: 'Skype'
      3: 'Yahoo'
      4: 'Facebook'
      5: 'Twitter'
      6: 'IRC'

  class Entities.ProfileContactsCollection extends Backbone.Collection
    model: Entities.ProfileContact