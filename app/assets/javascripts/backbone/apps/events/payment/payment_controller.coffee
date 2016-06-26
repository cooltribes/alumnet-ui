@AlumNet.module 'EventsApp.Payment', (Payment, @AlumNet, Backbone, Marionette, $, _) ->
  class Payment.Controller
    payEvent: (event_id)->
      event = AlumNet.request("event:find", event_id)
      current_user = AlumNet.current_user
      event.on 'find:success', (response, options)->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else if event.isPaidAlready()
          layout = AlumNet.request('event:layout', event)
          header = AlumNet.request('event:header', event)

          receiptView = new Payment.ReceiptView
            model: event
            current_user: AlumNet.current_user

          AlumNet.mainRegion.show(layout)
          AlumNet.execute 'show:footer'
          layout.header.show(header)
          layout.body.show(receiptView)
          #AlumNet.execute('render:events:submenu')
        else
          layout = AlumNet.request('event:layout', event)
          header = AlumNet.request('event:header', event)

          paymentView = new Payment.PaymentView
            model: event
            current_user: AlumNet.current_user

          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(paymentView)
          #AlumNet.execute('render:events:submenu')

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)