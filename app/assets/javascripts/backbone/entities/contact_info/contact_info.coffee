@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.ProfileContact extends Backbone.Model

    defaults:
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
      pattern = /([+]\d+)/
      if contact_type == '0'
        Backbone.Validation.validators.pattern(value, attr, 'email', @)     
      else if contact_type == '1'  
        required: true
        return "Add an international valid phone. (e.g. +0580000000 )"  
      else if contact_type == '2' #skype
        if value.indexOf(" ") > -1 || value == ''
          return "Enter a valid Skype account"
      else if contact_type == '7'
        required: true
        return "Add a valid website. (eg. https://www.example.com)"
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
      7: 'Web Site'

    # canShow: (friend, contact)->
    #   priv = if contact? then contact.get "privacy" else @get "privacy"      
    #   !((priv == 0 && friend != "current user") || (priv == 1 && friend != "accepted" && friend != "current user"))
      
    # privacy:
    #   1: 'Only me'
    #   2: 'Everyone'
    #   3: 'Friends'

  class Entities.ProfileContactsCollection extends Backbone.Collection
    model: Entities.ProfileContact