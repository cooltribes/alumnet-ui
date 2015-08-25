@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Personal extends Marionette.ItemView
    template: 'admin/users/show/templates/personal'
    className: 'container'
    templateHelpers: ->
      getCurrentLocation: @model.getCurrentLocation()
      getOriginLocation: @model.getOriginLocation()
      getBornDate: @model.getBornDate()
      getAge: @model.getAge()
      getRole: @model.getRole()