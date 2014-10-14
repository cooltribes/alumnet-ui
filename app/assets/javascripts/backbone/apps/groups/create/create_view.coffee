@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->

  class Create.Group extends Marionette.ItemView
    template: 'groups/create/templates/form'
    events:
      "click button.js-submit":"submitClicked"
    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      file = this.$('form :file')
      this.trigger("form:submit", data, file)
