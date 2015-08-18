@AlumNet.module 'AdminApp.Edit.Points', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

	class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/points/templates/layout'
    className: 'container'