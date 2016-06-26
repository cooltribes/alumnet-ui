@AlumNet.module 'AdminApp.PrizesList', (PrizesList, @AlumNet, Backbone, Marionette, $, _) ->
  class PrizesList.Controller
    prizesList: ->
      prizes = AlumNet.request('prize:entities', {})
      layoutView = new PrizesList.Layout
      prizesTable = new PrizesList.PrizesTable
         collection: prizes

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(prizesTable)
      AlumNet.execute('render:admin:prizes:submenu', undefined, 0, prizesTable)
      AlumNet.execute 'show:footer'