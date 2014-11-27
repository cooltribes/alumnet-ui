@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.User extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/'

    initialize: ->
      @messages = new AlumNet.Entities.MessagesCollection

      @profile = new Entities.Profile
      @profile.url = @urlRoot() + @id + '/profile'

      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'

      @on "change", ->
        @profile.fetch({async:false})

    currentUserCanPost: ->
      friendship_status = @get('friendship_status')
      if friendship_status == 'accepted' || friendship_status == 'current user'
        true
      else
        false

    isApproved: ->
      step = @profile.get "register_step"
      step == "approval" # || true
    






  class Entities.UserCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/users'

    model: Entities.User


  ### Other functions and utils###
  initializeUsers = ->
    Entities.users = new Entities.UserCollection

  API =
    getCurrentUserToken:  ->
      if gon.api_token
        gon.api_token
      else
        null

    getCurrentUser: (options = {}) ->
      @current_user ||= @getCurrentUserFromApi()

    getCurrentUserFromApi: ->
      user = new Entities.User
      user.url = AlumNet.api_endpoint + '/me'
      user.profile.url = AlumNet.api_endpoint + '/me/profile'
      user.messages.url = AlumNet.api_endpoint + '/me/messages'
      user.fetch({async:false})
      user

    getUserEntities: (querySearch)->
      initializeUsers() if Entities.users == undefined
      Entities.users.fetch
        data: querySearch
      Entities.users

    getNewUser: ->
      Entities.user = new Entities.User

    findUser: (id)->
      #Optimize: Verify if Entities.users is set and find the user there.
      user = new Entities.User
        id: id
      user.fetch
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success', response, options)
      user

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

  AlumNet.reqres.setHandler 'user:new', ->
    API.getNewUser()

  AlumNet.reqres.setHandler 'user:entities', (querySearch)->
    API.getUserEntities(querySearch)

  AlumNet.reqres.setHandler 'user:find', (id)->
    API.findUser(id)