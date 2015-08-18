@AlumNet.module 'AdminApp.Edit.Overview', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/overview/templates/layout'
    className: 'container'