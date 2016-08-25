@AlumNet.module 'AdminApp.Payments', (Payments, @AlumNet, Backbone, Marionette, $, _) ->
  class Payments.Controller
    showLayoutPayments: -> 
      AlumNet.setTitle('Admin - Payments')
      @layoutView = new Payments.Layout
      AlumNet.mainRegion.show(@layoutView)
      AlumNet.execute 'show:footer'
      @showAll()

    showAll: ->
      payments = AlumNet.request('payment:entities', {})
      view = new AlumNet.AdminApp.ListPayments.Layout
        collection: payments
      @layoutView.content_region.show(view)