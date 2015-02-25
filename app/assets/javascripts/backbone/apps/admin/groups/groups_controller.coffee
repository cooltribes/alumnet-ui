@AlumNet.module 'AdminApp.Groups', (Groups, @AlumNet, Backbone, Marionette, $, _) ->
  class Groups.Controller
    manageGroups: ->
      AlumNet.execute('render:admin:submenu')
      groups = AlumNet.request('group:entities:admin', {})

      layoutView = new Groups.Layout
      groupsTable = new Groups.GroupsTable
        collection: groups
        linksGroups: []

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(groupsTable)

      reRenderTable = (collection)->
        groupsTable.collection = collection if collection
        groupsTable.collection.fetch
          success: ->
            layoutView.table.show(groupsTable, { preventDestroy: true, forceShow: true })

      groupsTable.on 'childview:subgroups:show', (view, subgroups)->
        model = view.model
        @linksGroups.push({id: model.id, name: model.get('name')})
        reRenderTable(subgroups)

      groupsTable.on 'groups:bc',(index, subgroups)->
        newArray = @linksGroups.slice(0, (index + 1))
        @linksGroups = newArray
        reRenderTable(subgroups)

      groupsTable.on 'groups:home', ->
        @linksGroups = []
        reRenderTable(groups)



