@AlumNet.module 'AdminApp.Edit.Purchases', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

	class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/purchases/templates/layout'
    className: 'container'