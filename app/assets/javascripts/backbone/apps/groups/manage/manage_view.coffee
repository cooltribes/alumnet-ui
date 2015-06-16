@AlumNet.module 'GroupsApp.Manage', (Manage, @AlumNet, Backbone, Marionette, $, _) ->

  class Manage.EmptyView extends Marionette.ItemView
    template: 'groups/manage/templates/empty'

  class Manage.GroupView extends Marionette.ItemView
    template: 'groups/manage/templates/group'
    className: 'col-md-6 col-sm-6'
    ui:
      'leaveGroupLink': '#js-leave-group'
      'description':'#js-description'
    events:
      'click #js-leave-group': 'clickedLeaveLink'
      'click #js-subgroups': 'showSubgroups'

    clickedLeaveLink: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'click:leave'

    showSubgroups: (e)->
      id = $(e.currentTarget).attr("aria-controls")
      child = $(e.currentTarget).attr("data-child")
      $('#'+id).on('hidden.bs.collapse', () -> 
        $('#js-subgroups').html("Show subgroups ("+child+")"))
      $('#'+id).on('shown.bs.collapse', () -> 
        $('#js-subgroups').html("Hide subgroups ("+child+")"))

    onRender: ->
      @ui.description.linkify()

  class Manage.GroupsView extends Marionette.CompositeView
    template: 'groups/manage/templates/groups_container'
    childView: Manage.GroupView
    childViewContainer: ".groups-container"
    emptyView: Manage.EmptyView