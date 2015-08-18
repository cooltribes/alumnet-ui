@AlumNet.module 'AdminApp.Edit.Groups', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/groups/templates/layout'
    className: 'container'