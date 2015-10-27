@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.PasswordChange extends Backbone.Model
    validation:
      current_password:
        required: true
      password:
        required: true
        minLength: 8
        pattern: '^(?=.*[a-zA-Z])(?=.*[0-9])'
        msg: "Password must be at least 8 characters and be a combination of numbers and letters"
      confirm_password:
        required: true
        equalTo: 'password'
      valid_current_password: 'validateCurrentPassword'

    validateCurrentPassword: (value, attr, computedState) ->
        console.log value
        if value != "true"
          return 'Incorrect current password'


    