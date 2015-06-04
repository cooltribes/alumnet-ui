@AlumNet.module 'AdminApp.ActionsList', (ActionsList, @AlumNet, Backbone, Marionette, $, _) ->
  class ActionsList.Controller
    actionsList: ->
      actions = AlumNet.request('action:entities', {})
      layoutView = new ActionsList.Layout
      actionsTable = new ActionsList.ActionsTable
         collection: actions

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(actionsTable)
      # AlumNet.execute('render:admin:groups:submenu', undefined, 0)

      # reRenderTable = (collection)->
      #   groupsTable.collection = collection if collection
      #   groupsTable.collection.fetch
      #     success: ->
      #       layoutView.table.show(groupsTable, { preventDestroy: true, forceShow: true })

      # groupsTable.on 'childview:subgroups:show', (view, subgroups)->
      #   model = view.model
      #   @linksGroups.push({id: model.id, name: model.get('name')})
      #   reRenderTable(subgroups)

      # groupsTable.on 'groups:bc',(index, subgroups)->
      #   newArray = @linksGroups.slice(0, (index + 1))
      #   @linksGroups = newArray
      #   reRenderTable(subgroups)

      # groupsTable.on 'groups:home', ->
      #   @linksGroups = []
      #   reRenderTable(groups)