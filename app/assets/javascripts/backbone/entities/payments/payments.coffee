@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Payment extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/payments'

  class Entities.PaymentsCollection extends Backbone.Collection
    model: Entities.Payment

  API =
    createPayment: (attrs)->
      payment = new Entities.Payment(attrs)
      payment.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      payment

    getPayments: (user_id)->
      payments = new Entities.PaymentsCollection
      payments.url = AlumNet.api_endpoint + '/users/' + user_id + '/payments'
      payments.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      payments

    getPaymentEntities: (querySearch)->
      payments = new Entities.PaymentsCollection
      payments.url = AlumNet.api_endpoint + '/payments'
      payments.fetch
        data: querySearch
        success: (collection, response, options) ->
          payments.trigger('fetch:success', collection)
      payments

  AlumNet.reqres.setHandler 'payment:create', (attrs) ->
    API.createPayment(attrs)

  AlumNet.reqres.setHandler 'payment:entities', (querySearch) ->
    API.getPaymentEntities(querySearch)