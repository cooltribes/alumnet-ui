@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Experience extends Backbone.Model
    # urlRoot: ->
    #   AlumNet.api_endpoint + '/experience'

    # initialize: ->


    ###
    0: aiesec
    1: alumni
    2: academic
    3: prodessional

    ###  
    defaults:
      first: false,
      name: "",
      organization_name: "",
      start_year: "",
      start_month: "",
      end_year: "",
      end_month: "",
      description: "",
      country_id: "",
      city_id: "",
      local_comitee: "",
      internship: 0,


    validation:
      name:
        required: true
      start_year:
        required: true
      end_year:
        required: true
        fn: (value, attr, computedState) ->
  
          if (value == 0)
            if (@get("exp_type") == 0 || @get("exp_type") == 1)
              return "#{attr} is required"
            # else
          else 
            if ( value < @get("start_year"))
              return "End year has to be greater or equal than start year"

          console.log value    


      description:
        required: true
      country_id:
        required: true
      organization_name:
        required: (value, attr, computedState) ->
          @get("exp_type") == 2 || @get("exp_type") == 3
      # internship:
      #   required: (value, attr, computedState) ->
      #     @get("exp_type") == 3

      # city:
      #   required: true
      # local_comitee:
      #   required: true
      # residence_country:
      #   required: true
      # residence_city:
      #   required: true



  class Entities.ExperienceCollection extends Backbone.Collection
    # url: ->
    #   AlumNet.api_endpoint + '/users'

    model: Entities.Experience

  # initializeUsers = ->
  #   Entities.users = new Entities.UserCollection

  # API =
  #   getCurrentUserToken:  ->
  #     if gon.current_user
  #       gon.current_user.auth_token
  #     else
  #       null

  #   getCurrentUser: (options = {}) ->
  #     @current_user ||= @getCurrentUserFromApi()

  #   getCurrentUserFromApi: ->
  #     # console.log "fromapi"
  #     # console.log @current_user
  #     user = new Entities.User
  #     user.url = AlumNet.api_endpoint + '/me'
  #     # console.log user.url
  #     user.fetch()
  #     # console.log "after fetch"
  #     # console.log user
  #     user

  #   getUserEntities: (querySearch)->
  #     initializeUsers() if Entities.users == undefined
  #     Entities.users.fetch
  #       data: querySearch
  #     Entities.users

  #   getNewUser: ->
  #     Entities.user = new Entities.User

  #   createInvitation: (attrs)->
  #     invitation = new Entities.Invitation(attrs)
  #     invitation.save attrs,
  #       error: (model, response, options) ->
  #         model.trigger('save:error', response, options)
  #       success: (model, response, options) ->
  #         model.trigger('save:success', response, options)
  #     invitation

  # AlumNet.reqres.setHandler 'user:token', ->
  #   API.getCurrentUserToken()

  # AlumNet.reqres.setHandler 'get:current_user', (options = {}) ->
  #     if options.refresh
  #       AlumNet.request 'current_user:refresh', options
  #     else
  #       API.getCurrentUser()

  # AlumNet.reqres.setHandler 'current_user:refresh', (options = {}) ->
  #   user = AlumNet.request('get:current_user')
  #   options = _.extend options, url: AlumNet.api_endpoint + '/me'
  #   user.fetch options

  # AlumNet.reqres.setHandler 'temp:current_user', (options = {}) ->
  #   API.getCurrentUser(options)

  # AlumNet.reqres.setHandler 'user:invitation:send', (attrs) ->
  #   API.createInvitation(attrs)

  # AlumNet.reqres.setHandler 'user:new', ->
  #   API.getNewUser()

  # AlumNet.reqres.setHandler 'user:entities', (querySearch)->
  #   API.getUserEntities(querySearch)