@AlumNet.module 'AdminApp.Edit.Admin', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/admin/templates/layout'
    className: 'container'