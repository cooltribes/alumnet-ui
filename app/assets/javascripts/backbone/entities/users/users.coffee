@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.User extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users'

    initialize: ->
      @profile = new Entities.Profile

      @on "change", ->
        @profile.url = AlumNet.api_endpoint + '/me/profile'
        @profile.fetch()

  class Entities.UserCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/users'

    model: Entities.User


  ### Other functions and utils###


  initializeUsers = ->
    Entities.users = new Entities.UserCollection

  API =
    getCurrentUserToken:  ->
      if gon.current_user
        gon.current_user.api_token
      else
        null

    getCurrentUser: (options = {}) ->
      @current_user ||= @getCurrentUserFromApi()

    getCurrentUserFromApi: ->
      user = new Entities.User
      user.url = AlumNet.api_endpoint + '/me'
      user

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

  AlumNet.reqres.setHandler 'user:token', ->
    API.getCurrentUserToken()

  AlumNet.reqres.setHandler 'get:current_user', (options = {}) ->
      if options.refresh
        AlumNet.request 'current_user:refresh', options
      else
        API.getCurrentUser()

  AlumNet.reqres.setHandler 'current_user:refresh', (options = {}) ->
    user = AlumNet.request('get:current_user')
    options = _.extend options, url: AlumNet.api_endpoint + '/me'
    user.fetch options

  AlumNet.reqres.setHandler 'temp:current_user', (options = {}) ->
    API.getCurrentUser(options)

  AlumNet.reqres.setHandler 'user:invitation:send', (attrs) ->
    API.createInvitation(attrs)

  AlumNet.reqres.setHandler 'user:new', ->
    API.getNewUser()

  AlumNet.reqres.setHandler 'user:entities', (querySearch)->
    API.getUserEntities(querySearch)