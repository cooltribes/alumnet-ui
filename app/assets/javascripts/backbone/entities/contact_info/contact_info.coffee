@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.ProfileContact extends Backbone.Model
    # privacy:
    #   1: 'Only me'
    #   2: 'Everyone'
    #   3: 'Friends'

    defaults:
      privacy: 2
      showDelete: true
      readOnly: false

    validation:
      contact_type:
        required: true
      info: 'customValidation'
      privacy:
        required: true

    customValidation: (value, attr, computedState)->
      contact_type = @get('contact_type')
      pattern = /^\+?\d{1,3}?[- .]?\(?(?:\d{2,3})\)?[- .]?\d\d\d[- .]?\d\d\d\d$/
      if contact_type == '0'
        Backbone.Validation.validators.pattern(value, attr, 'email', @)
      else if contact_type == '1'
        Backbone.Validation.validators.pattern(value, attr, pattern, @)
      else if contact_type == '2' #skype
        if value.indexOf(" ") > -1 || value == ''
          return "Enter a valid Skype account"
      else if contact_type == '7'
        Backbone.Validation.validators.pattern(value, attr, 'url', @)
       else if contact_type == '8'
        Backbone.Validation.validators.pattern(value, attr, 'url', @)
      else
        Backbone.Validation.validators.required(value, attr, true, @)

    contactTypes: [
      { value: 0, text: 'Email', placeholder: 'email@example.com'  }
      { value: 1, text: 'Phone', placeholder: 'PhoneNumber'  }
      { value: 2, text: 'Skype', placeholder: 'Skype'  }
      { value: 3, text: 'Yahoo', placeholder: 'Yahoo account'  }
      { value: 4, text: 'Facebook', placeholder: '/Facebook'  }
      { value: 5, text: 'Twitter', placeholder: '@Twitter'  }
      { value: 6, text: 'IRC', placeholder: 'Account'  }
      { value: 7, text: 'Web Site', placeholder: 'https://www.example.com'  }
      { value: 8, text: 'LinkedIn', placeholder: 'https://www.LinkedIn.com/example'  }
    ]

    findContactType: (value)->
      _.findWhere @contactTypes, { value: parseInt(value) }

    contactTypesToSelect2: ->
      result = []
      _.each @contactTypes, (element, list)->
        result.push { id: element.value, text: element.text }
      result

  class Entities.ProfileContactsCollection extends Backbone.Collection
    model: Entities.ProfileContact