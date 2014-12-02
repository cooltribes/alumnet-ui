@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.ProfileSkill extends Backbone.Model        
    defaults:       
      language_id: "",
      
      
    

    validation:
      language_id:
        required: true
      level:
        required: true
        range: [1, 5]     



  class Entities.ProfileSkillCollection extends Backbone.Collection    
    model: Entities.ProfileSkill



  ### ----------Languages for dropdowns----------- ###
  
  class Entities.Skill extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/skills/'

  class Entities.Skills extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/skills'
    model: Entities.Skill

  API =
    getLanguagesHtml: (collection)  ->      
      html = '<option value="">Select a language</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 

      html


  AlumNet.reqres.setHandler 'skills:html', (collection) ->
    API.getLanguagesHtml(collection)  
  

  