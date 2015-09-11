@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Payment extends Marionette.ItemView
    template: 'admin/users/show/templates/_payment'
    tagName: 'tr'

    templateHelpers: ->
    	getCreatedDate: ->
    		date = new Date(@payment.created_at)
    		date.toDateString()

  class UserShow.Payments extends Marionette.CompositeView
    template: 'admin/users/show/templates/payments'
    childView: UserShow.Payment
    childViewContainer: '#js-payments-container'
    childViewOptions: ->
      user: @model