@AlumNet.module 'AdminApp.ActionsList', (ActionsList, @AlumNet, Backbone, Marionette, $, _) ->
  class ActionsList.Controller
    actionsList: ->
      actions = AlumNet.request('action:entities', {})
      layoutView = new ActionsList.Layout
      actionsTable = new ActionsList.ActionsTable
         collection: actions

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(actionsTable)