@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Action extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/actions/'

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Group name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Group description is required, must be less than 2048 characters"

  class Entities.ActionCollection extends Backbone.Collection
    model: Entities.Action

    url: ->
      AlumNet.api_endpoint + '/actions'

  initializeActions = ->
    Entities.actions = new Entities.ActionCollection

  API =
    getActionEntities: (querySearch)->
      initializeActions() if Entities.actions == undefined
      Entities.actions.fetch
        data: querySearch
        success: (model, response, options) ->
          Entities.actions.trigger('fetch:success')
      Entities.actions

    getNewAction: ->
      new Entities.Action

    findAction: (id)->
      action = @findActionOnApi(id)

    findActionOnApi: (id)->
      action = new Entities.Action
        id: id
      action.fetch
        # async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      action

  AlumNet.reqres.setHandler 'action:new', ->
    API.getNewAction()

  AlumNet.reqres.setHandler 'action:entities', (querySearch) ->
    API.getActionEntities(querySearch)

  AlumNet.reqres.setHandler 'action:find', (id)->
    API.findAction(id)