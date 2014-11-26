@AlumNet.module 'GroupsApp.Manage', (Manage, @AlumNet, Backbone, Marionette, $, _) ->
  class Manage.GroupView extends Marionette.ItemView
    template: 'groups/manage/templates/group'
    ui:
      'leaveGroupLink': '#js-leave-group'
    events:
      'click #js-leave-group': 'clickedLeaveLink'

    clickedLeaveLink: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'click:leave'

  class Manage.GroupsView extends Marionette.CompositeView
    template: 'groups/manage/templates/groups_container'
    childView: Manage.GroupView
    childViewContainer: ".groups-container"