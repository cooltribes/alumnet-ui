@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Profile extends Backbone.Model
    # urlRoot: ->
    #   # AlumNet.api_endpoint + '/users/' + @user_id + "/profile"
    #   AlumNet.api_endpoint + '/users/'

    # setUrl: ->
    #   @url = AlumNet.api_endpoint + '/users/' + @get("user_id") + "/profile"

    validation:
      first_name:
        required: true
      last_name:
        required: true
      born:
        required: true
      genre:
        required: true
        oneOf: ["F", "M"]
      birth_country:
        required: true
      birth_city:
        required: true
      residence_country:
        required: true
      residence_city:
        required: true