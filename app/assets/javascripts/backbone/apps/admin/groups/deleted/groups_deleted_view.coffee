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
        country = model.get('country').name
        city = model.get('city').name
        array = []
        array.push(country) unless country == ""
        array.push(city) unless city == ""
        array.join(", ")
      getSubgroupsCount: ->
        model.get('children').length
      getParentName: ->
        parent = model.get('parent')
        if parent then parent.name else "none"

    ui:
      'restoreLink': '#js-group-restore'
      'destroyLink': '#js-group-destroy'

    events:
      'click @ui.restoreLink': 'restoreClicked'
      'click @ui.destroyLink': 'destroyClicked'

    restoreClicked: (e)->
      e.preventDefault()
      collection = @model.collection
      @model.save {},
        success: (model)->
          collection.remove(model)


    destroyClicked: (e)->
      e.preventDefault()
      resp = confirm('This action destroy the group permanently. ¿Are you sure?')
      if resp
        @model.destroy()

    renderView: ->
      @render()

  class GroupsDeleted.GroupsTable extends Marionette.CompositeView
    template: 'admin/groups/deleted/templates/groups_deleted_table'
    childView: GroupsDeleted.GroupView
    childViewContainer: "#groups-deleted-table tbody"

    initialize: ()->
      document.title='AlumNet - Groups Management'