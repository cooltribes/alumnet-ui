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
      avatar:
        required: true
      born:
        required: true
      birth_country:
        required: true
      birth_city:
        required: true
      residence_country:
        required: true
      residence_city:
        required: true


  # AlumNet.reqres.setHandler 'user:token', ->
  #   API.getCurrentUserToken()

  # AlumNet.reqres.setHandler 'get:current_user', (options = {}) ->
  #     if options.refresh
  #       AlumNet.request 'current_user:refresh', options
  #     API.getCurrentUser()

  # AlumNet.reqres.setHandler 'current_user:refresh', (options = {}) ->
  #   user = AlumNet.request('get:current_user')
  #   options = _.extend options, url: AlumNet.api_endpoint + '/users/me'
  #   user.fetch options


  # AlumNet.reqres.setHandler 'user:invitation:send', (attrs) ->
  #   API.createInvitation(attrs)

  # AlumNet.reqres.setHandler 'user:new', ->
  #   API.getNewUser()

  # AlumNet.reqres.setHandler 'user:entities', (querySearch)->
  #   API.getUserEntities(querySearch)