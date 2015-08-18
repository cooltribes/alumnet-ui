@AlumNet.module 'AdminApp.Edit.Events', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/events/templates/layout'
    className: 'container'