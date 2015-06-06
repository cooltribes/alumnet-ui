@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Prize extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/prizes/'

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Prize name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Prize description is required, must be less than 2048 characters"

  class Entities.PrizeCollection extends Backbone.Collection
    model: Entities.Prize

    url: ->
      AlumNet.api_endpoint + '/prizes'

  initializePrizes = ->
    Entities.prizes = new Entities.PrizeCollection

  API =
    getPrizeEntities: (querySearch)->
      initializePrizes() if Entities.prizes == undefined
      Entities.prizes.fetch
        data: querySearch
        success: (model, response, options) ->
          Entities.prizes.trigger('fetch:success')
      Entities.prizes

    getNewPrize: ->
      new Entities.Prize

    findPrize: (id)->
      prize = @findPrizeOnApi(id)

    findPrizeOnApi: (id)->
      prize = new Entities.Prize
        id: id
      prize.fetch
        # async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      prize

  AlumNet.reqres.setHandler 'prize:new', ->
    API.getNewPrize()

  AlumNet.reqres.setHandler 'prize:entities', (querySearch) ->
    API.getPrizeEntities(querySearch)

  AlumNet.reqres.setHandler 'prize:find', (id)->
    API.findPrize(id)