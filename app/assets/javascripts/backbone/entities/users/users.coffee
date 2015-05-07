@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.User extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/'

    initialize: ->
      @messages = new Entities.MessagesCollection
      @notifications = new Entities.NotificationsCollection

      @profile = new Entities.Profile
      @profile.url = @urlRoot() + @id + '/profile'

      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'

      @on "change", ->
        @profile.fetch({async:false})


    currentUserCanPost: ->
      friendship_status = @get('friendship_status')
      if friendship_status == 'accepted'
        true
      else
        false

    isApproved: ->
      step = @profile.get "register_step"
      step == "approval"

    isAdmin: ->
      @get "is_admin"

    isAlumnetAdmin: ->
      @get "is_alumnet_admin" || @get "is_system_admin"

    isActive: ->
      status = @get "status"
      if status.value == 1 then true else false

    isBanned: ->
      status = @get "status"
      if status.value == 2 then true else false

    getName: ()->
      if @get("name").trim()
        return @get("name")
      "No name registered"

    getEmail: ()->
      @get "email"

    getGender: ()->
      if @profile.get("gender")
        return @profile.get("gender")
      "No gender"

    getBornDate: ()->
      born = @profile.get('born')
      array = []
      array.push(born.year) if born.year
      array.push(born.month) if born.month
      array.push(born.day) if born.day
      array.join("/")

    getBornComplete: ()->
      date = if @profile.get("born") then @profile.get("born") else "No birth date"
      array = []
      array.push(@getOriginLocation())
      array.push(@getBornDate()) if @getBornDate()
      array.join(" in ")

    getAge: ()->
        if @profile.get("born")
          return moment().diff(@profile.get("born"), 'years')
        "No age"

    getJoinTime: ()->
      moment(@created_at).fromNow()

    getOriginLocation: ()->
      if @profile.get("birth_city")
        return "#{@profile.get("birth_city").text} - #{@profile.get("birth_country").text}"
      null

    getCurrentLocation: ()->
      if @profile.get("residence_city")
        return "#{@profile.get("residence_city").text} - #{@profile.get("residence_country").text}"
      null

    getLC: ()->
      if @profile.get("local_committee")
        return @profile.get("local_committee").name
      "No local committee"

    areFriends: ()->
      @get('friendship_status') == 'accepted'

    isCurrentUser: ()->
      @id == AlumNet.current_user.id

    getRole: ()->
      if @get('is_system_admin')
        "system"
      else if @get('is_alumnet_admin')
        "alumnet"
      else if @get('is_regional_admin')
        "regional"
      else if @get('is_nacional_admin')
        "nacional"
      else
        "regular"

    incrementCount: (counter, val = 1)->
      value = @get("#{counter}_count")
      @set("#{counter}_count", value + val)
      @get("#{counter}_count")

    decrementCount: (counter, val = 1)->
      value = @get("#{counter}_count")
      return if value == 0
      @set("#{counter}_count", value - val)
      @get("#{counter}_count")

    setCount: (counter, value = 0)->
      @set("#{counter}_count", value) if @get("#{counter}_count") != value


  class Entities.UserCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/users'
    model: Entities.User

  class Entities.DeletedUser extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/deleted/users/'

  class Entities.DeletedUserCollection extends Backbone.Collection
    model: Entities.DeletedUser
    url: ->
      AlumNet.api_endpoint + '/admin/deleted/users/'


  ### Other functions and utils###
  initializeUsers = ->
    Entities.users = new Entities.UserCollection

  initializeUsersList = ->
    Entities.allUsers = new Entities.UserCollection

  API =
    getCurrentUserToken:  ->
      if gon.auth_token
        gon.auth_token
      else
        null

    getCurrentUser: () ->
      @current_user ||= @getCurrentUserFromApi()

    getCurrentUserFromApi: ->
      user = new Entities.User
      user.url = AlumNet.api_endpoint + '/me'
      user.profile.url = AlumNet.api_endpoint + '/me/profile'
      user.messages.url = AlumNet.api_endpoint + '/me/messages'
      user.notifications.url = AlumNet.api_endpoint + '/me/notifications'

      user.fetch({async:false})
      user

    getUserEntities: (querySearch, options)->
      initializeUsers() if Entities.users == undefined
      # Entities.users.fetch()
      if !(options.fetch?) then options.fetch = true

      if options.fetch
        Entities.users.fetch
          data: querySearch
      Entities.users

    #List of all users for administration
    getUsersList: (querySearch)->
      initializeUsersList() if Entities.allUsers == undefined
      Entities.allUsers.url = AlumNet.api_endpoint + '/admin/users'
      Entities.allUsers.comparator = "id"
      Entities.allUsers.fetch
        data: querySearch
      Entities.allUsers

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

    getUsersDeleted: (querySearch)->
      users = new Entities.DeletedUserCollection
      users.fetch
        data: querySearch
      users

  AlumNet.reqres.setHandler 'user:token', ->
    API.getCurrentUserToken()

  AlumNet.reqres.setHandler 'get:current_user', (options = {}) ->
      if options.refresh
        AlumNet.request 'current_user:refresh', options
        # API.getCurrentUserFromApi()
      else
        API.getCurrentUser()

  AlumNet.reqres.setHandler 'current_user:refresh', (options = {}) ->
    user = AlumNet.request('get:current_user')
    # options = _.extend options, url: AlumNet.api_endpoint + '/me'
    user.fetch options

  AlumNet.reqres.setHandler 'user:new', ->
    API.getNewUser()

  AlumNet.reqres.setHandler 'user:entities', (querySearch, options = {})->
    API.getUserEntities(querySearch, options)

  AlumNet.reqres.setHandler 'admin:user:entities', (querySearch)->
    API.getUsersList(querySearch)

  AlumNet.reqres.setHandler 'user:find', (id)->
    API.findUser(id)

  AlumNet.reqres.setHandler 'user:entities:deleted', (querySearch)->
    API.getUsersDeleted(querySearch)
