@AlumNet.module 'AdminApp.BannerList', (BannerList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class BannerList.Controller
    bannerList: ->
      banner = AlumNet.request('banner:entities:admin', {})

      layoutView = new BannerList.Layout
      bannerTable = new BannerList.BannerTable
      createBanner = new BannerList.CreateView

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(bannerTable)
      layoutView.create.show(createBanner)
      
      AlumNet.execute('render:admin:banner:submenu', undefined, 0)
      