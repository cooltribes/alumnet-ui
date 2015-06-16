@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.UserPrize extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/prizes'

  class Entities.MembershipsCollection extends Backbone.Collection
    model: Entities.Membership

  API =
    createUserPrize: (attrs)->
      user_prize = new Entities.UserPrize(attrs)
      user_prize.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      user_prize

  AlumNet.reqres.setHandler 'user_prize:create', (attrs) ->
    API.createUserPrize(attrs)