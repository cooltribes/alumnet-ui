@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.User extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/'

    initialize: ->
      @messages = new Entities.MessagesCollection
      @notifications = new Entities.NotificationsCollection
      @friendship_notifications = new Entities.FriendshipNotificationsCollection

      @profile = new Entities.Profile
      @profile.url = @urlRoot() + @id + '/profile'
      @posts = new Entities.PostCollection
      @posts.url = @urlRoot() + @id + '/posts'

      @on "change", ->
        @profile.fetch({async: false})

    getApprovalStatus: ->
      @get('approval_status')

    profile_fetch: ->
      @profile.fetch({async: false})

    currentUserCanPost: ->
      friendship_status = @get('friendship_status')
      if friendship_status == 'accepted'
        true
      else
        false

    isApproved: ->
      step = @profile.get "register_step"
      step == "completed"

    isAdmin: ->
      @get "is_admin"

    isExternal: ->
      @profile.get("role") == "External"

    isAlumnetAdmin: ->
      @get "is_alumnet_admin" || @get "is_system_admin"

    isRegionalAdmin: ->
      @get "is_regional_admin"

    isNacionalAdmin: ->
      @get "is_nacional_admin"

    isInactive: ->
      status = @get "status"
      status.value == 0

    isActive: ->
      status = @get "status"
      status.value == 1

    isBanned: ->
      status = @get "status"
      status.value == 2

    showOnboarding: ->
      @get "show_onboarding"

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
      array.push(born.day) if born.day
      array.push(born.month) if born.month
      array.push(born.year) if born.year
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
        return "#{@profile.get("birth_city").name} - #{@profile.get("birth_country").name}"
      null

    getCurrentLocation: ()->
      if @profile.get("residence_city")
        return "#{@profile.get("residence_city").name} - #{@profile.get("residence_country").name}"
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
      else if @get('is_external')
        "external"
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

  class Entities.DeletedUser extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/deleted/users/'

  class Entities.AdminUserCollection extends Backbone.PageableCollection
    model: Entities.User
    url: ->
      AlumNet.api_endpoint + '/admin/users'

    state:
      pageSize: 10
      sortKey: 'users.id'

    queryParams:
      order: "order_by"

    parseState: (response, queryParams, state, options)->
      { totalRecords: response.totalRecords }

    parseRecords: (response, options)->
      @totalRecords = response.totalRecords
      response.users


  class Entities.UserCollection extends Backbone.Collection
    model: Entities.User
    rows: 15
    page: 1
    url: ->
      AlumNet.api_endpoint + '/users'

  class Entities.DeletedUserCollection extends Backbone.Collection
    model: Entities.DeletedUser
    url: ->
      AlumNet.api_endpoint + '/admin/deleted/users/'

  class Entities.ContactsInAlumnet extends Backbone.Collection
    model: Entities.User
    url: ->
      AlumNet.api_endpoint + '/me/contacts/in_alumnet'

  class Entities.AdminUser extends Entities.User

    contactsCollection: ->
      collection = new AlumNet.Entities.ProfileContactsCollection @get('contacts')
      collection.url = AlumNet.api_endpoint + "/profiles/#{@get('profile_id')}/contact_infos"
      collection

    experiencesCollection: ->
      collection = new AlumNet.Entities.ExperienceCollection @get('experiences')
      collection.url = AlumNet.api_endpoint + "/profiles/#{@get('profile_id')}/experiences"
      collection

    eventsCollection: ->
      collection = new AlumNet.Entities.EventsCollection @get('events'),
        eventable: 'users'
        eventable_id: @id
      collection

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
      user.friendship_notifications.url = AlumNet.api_endpoint + '/me/notifications/friendship'

      user.fetch({async:false})
      user

    getUserPagination: ->
      newUser = new Entities.UserCollection
      newUser.url = AlumNet.api_endpoint + '/users'
      newUser

    getUserEntities: (querySearch, options)->
      initializeUsers() if Entities.users == undefined
      Entities.users.page = 1
      Entities.users.url = AlumNet.api_endpoint + '/users?page='+Entities.users.page+'&per_page='+Entities.users.rows
      Entities.users.fetch
        data: querySearch
        success: (model, response, options) ->
          Entities.users.trigger('fetch:success')
      Entities.users

    #List of all users for administration
    getUsersList: (querySearch)->
      users = new Entities.AdminUserCollection
      #users.url = AlumNet.api_endpoint + '/admin/users'
      users
      # initializeUsersList() if Entities.allUsers == undefined
      # Entities.allUsers.comparator = "id"
      # Entities.allUsers.fetch
      #   data: querySearch
      # Entities.allUsers

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

  AlumNet.reqres.setHandler 'user:pagination', ->
    API.getUserPagination()

  AlumNet.reqres.setHandler 'admin:user:entities', (querySearch)->
    API.getUsersList(querySearch)

  AlumNet.reqres.setHandler 'user:find', (id)->
    API.findUser(id)

  AlumNet.reqres.setHandler 'user:entities:deleted', (querySearch)->
    API.getUsersDeleted(querySearch)
