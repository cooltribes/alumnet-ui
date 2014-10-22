@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.User extends Backbone.Model
    url: 'http://localhost:4000/users'

  # This can change, because now an invitation is an a membership in invitation mode
  class Entities.Invitation extends Backbone.Model
    url: 'http://localhost:4000/users'

    initialize: ->
      @url = "#{@url}/#{@get('user_id')}/invite"

  class Entities.UserCollection extends Backbone.Collection
    url: 'http://localhost:4000/users'
    model: Entities.User

  initializeUsers = ->
    Entities.users = new Entities.UserCollection

  API =
    getUserEntities: (querySearch)->
      initializeUsers() if Entities.users == undefined
      Entities.users.fetch
        data: querySearch
      Entities.users
    getNewUser: ->
      Entities.user = new Entities.User
    createInvitation: (attrs)->
      invitation = new Entities.Invitation(attrs)
      invitation.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      invitation

  AlumNet.reqres.setHandler 'user:invitation:send', (attrs) ->
    API.createInvitation(attrs)

  AlumNet.reqres.setHandler 'user:new', ->
    API.getNewUser()

  AlumNet.reqres.setHandler 'user:entities', (querySearch)->
    API.getUserEntities(querySearch)