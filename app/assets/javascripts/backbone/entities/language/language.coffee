@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.ProfileLanguage extends Backbone.Model        
    defaults: 
      first: false,
      language_id: "",
      level: 3,

      
    

    validation:
      language_id:
        required: true
      level:
        required: true
        range: [1, 5]     

    

  class Entities.ProfileLanguageCollection extends Backbone.Collection    
    model: Entities.ProfileLanguage



  ### ----------Languages for dropdowns----------- ###
  
  class Entities.Language extends Backbone.Model    
    urlRoot: ->
      AlumNet.api_endpoint + '/languages/'

  class Entities.Languages extends Backbone.Collection    
    url: ->
      AlumNet.api_endpoint + '/languages'
    model: Entities.Language

  API =
    getLanguagesHtml: (collection)  ->      
      html = '<option value="">Select a language</option>'            

      _.forEach collection.models, (item, index, list)->        
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>' 

      html


  AlumNet.reqres.setHandler 'languages:html', (collection) ->
    API.getLanguagesHtml(collection)  

  