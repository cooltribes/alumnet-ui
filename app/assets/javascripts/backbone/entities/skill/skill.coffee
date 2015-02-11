@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Entities.Skill extends Backbone.Model
  
  class Entities.ProfileSkill extends Backbone.Model
    # urlRoot: ->
    # AlumNet.api_endpoint + '/skills/'

  class Entities.Skills extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/skills'
    model: Entities.ProfileSkill

  API =
    getLanguagesHtml: (collection)  ->
      html = '<option value="">Select a language</option>'

      _.forEach collection.models, (item, index, list)->
        html += '<option value="' + (item.get("id")) + '">' + item.get("name") + '</option>'

      html

  AlumNet.reqres.setHandler 'skills:html', (collection) ->
    API.getLanguagesHtml(collection)


