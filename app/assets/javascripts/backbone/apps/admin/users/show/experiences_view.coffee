@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Experience extends Marionette.ItemView
    template: 'admin/users/show/templates/_overview_experience'
    templateHelpers: ->
      getStartDate: @model.getStartDate()
      getEndDate: @model.getEndDate()

  class UserShow.Experiences extends Marionette.CompositeView
    template: 'admin/users/show/templates/experiences'
    className: 'container'
    childView: UserShow.Experience
    childViewContainer: '#js-experiences-container'
    childViewOptions: ->
      user: @model

    templateHelpers: ->
      showSkills: @showSkills()

    showSkills: ->
      return "No skills" if @model.get('skills').length == 0
      links = []
      _.each @model.get('skills'), (element)->
        links.push(element.name)
      links.join(", ")