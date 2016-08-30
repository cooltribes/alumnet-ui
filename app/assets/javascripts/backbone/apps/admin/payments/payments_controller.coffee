@AlumNet.module 'AdminApp.Payments', (Payments, @AlumNet, Backbone, Marionette, $, _) ->
  class Payments.Controller
    showLayoutPayments: -> 
      AlumNet.setTitle('Admin - Payments')
      @layoutView = new Payments.Layout
      AlumNet.mainRegion.show(@layoutView)
      AlumNet.execute 'show:footer'
      @showAll()

    showAll: ->
      self = @
      payments = AlumNet.request('payment:entities', {})
      payments.on 'fetch:success', (collection)->
        view = new AlumNet.AdminApp.ListPayments.Layout
          collection: collection
        self.layoutView.content_region.show(view)