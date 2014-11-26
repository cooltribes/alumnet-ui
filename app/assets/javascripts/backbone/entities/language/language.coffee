@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.ProfileLanguage extends Backbone.Model        
    defaults: 
      language_id: "",
      level: 5,
      
    

    validation:
      language_id:
        required: true
      level:
        required: true
        range: [1, 10]     



  class Entities.ProfileLanguageCollection extends Backbone.Collection    
    model: Entities.Experience

  