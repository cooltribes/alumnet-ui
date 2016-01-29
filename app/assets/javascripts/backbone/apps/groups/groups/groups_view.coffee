@AlumNet.module 'GroupsApp.Groups', (Groups, @AlumNet, Backbone, Marionette, $, _) ->

  class Groups.EmptyView extends Marionette.ItemView
    template: 'groups/groups/templates/empty'

  class Groups.GroupView extends Marionette.ItemView
    template: 'groups/groups/templates/group'
    className: 'listGroups'

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

  class Groups.GroupsView extends Marionette.CompositeView
    template: 'groups/groups/templates/groups_container'
    childView: Groups.GroupView
    childViewContainer: ".groups-container"
    emptyView: Groups.EmptyView
    
    onRender: ->
      $("#iconsTypeGroups").addClass("hide");