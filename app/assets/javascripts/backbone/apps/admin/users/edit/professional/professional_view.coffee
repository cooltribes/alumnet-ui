@AlumNet.module 'AdminApp.Edit.Professional', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/professional/templates/layout'
    className: 'container'