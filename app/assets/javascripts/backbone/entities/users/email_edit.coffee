@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.EmailEdit extends Backbone.Model
    validation:      
      email:
        required: true       
        msg: "Email can't be blank"      
      
