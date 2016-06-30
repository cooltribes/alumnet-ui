@AlumNet.module 'AdminApp.BannerList', (BannerList, @AlumNet, Backbone, Marionette, $, _) ->
  class BannerList.Controller
    bannerList: ->
        
      banner = AlumNet.request('banner:entities:admin', {})
      
      bannerCollection = new AlumNet.Entities.BannerCollection
      bannerCollection.fetch()

      layoutView = new BannerList.Layout
      bannerTable = new BannerList.BannerTable
        collection: bannerCollection
      createBanner = new BannerList.CreateView
        model: new AlumNet.Entities.Banner
        collection: bannerCollection

      AlumNet.execute('render:admin:banner:submenu', undefined, 0)


      AlumNet.mainRegion.show(layoutView)
      AlumNet.execute 'show:footer'
      layoutView.table.show(bannerTable)

      layoutView.create.show(createBanner)

      bannerTable.on 'banner:count', ()->
        bannerCollection.each (model)->     
          index = bannerCollection.indexOf(model)
          order = { order: model.get('order')}
          model.set('order', index)
          model.save()
        bannerCollection.sortBy (model) ->
          model.order
    
      
              

