@AlumNet.module 'AdminApp.BanerList', (BanerList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class BanerList.Controller
    banerList: ->
      baner = AlumNet.request('baner:entities:admin', {})

      layoutView = new BanerList.Layout
      banerTable = new BanerList.BanerTable
      createBaner = new BanerList.CreateView

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(banerTable)
      layoutView.create.show(createBaner)
      
      AlumNet.execute('render:admin:baner:submenu', undefined, 0)
      