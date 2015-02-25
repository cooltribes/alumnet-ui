@AlumNet.module 'AdminApp.GroupsDeleted', (GroupsDeleted, @AlumNet, Backbone, Marionette, $, _) ->
  class GroupsDeleted.Layout extends Marionette.LayoutView
    template: 'admin/groups/deleted/templates/layout'
    className: 'container'
    regions:
      search: '#search-region'
      table: '#table-region'

  class GroupsDeleted.GroupView extends Marionette.ItemView
    template: 'admin/groups/deleted/templates/group'
    tagName: "tr"

    initialize: ->
      @listenTo(@model, 'render:view', @renderView)

    templateHelpers: ->
      model = @model
      getLocation: ->
        country = model.get('country').text
        city = model.get('city').text
        array = []
        array.push(country) unless country == ""
        array.push(city) unless city == ""
        array.join(", ")
      getSubgroupsCount: ->
        model.get('children').length
      getAlumniCount: ->
        model.get('members').length
      getAdminsCount: ->
        model.get('admins').length
      getParentName: ->
        parent = model.get('parent')
        if parent then parent.name else "none"

    renderView: ->
      @render()

  class GroupsDeleted.GroupsTable extends Marionette.CompositeView
    template: 'admin/groups/deleted/templates/groups_deleted_table'
    childView: GroupsDeleted.GroupView
    childViewContainer: "#groups-deleted-table tbody"