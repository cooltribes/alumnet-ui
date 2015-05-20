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
<<<<<<< HEAD
        
=======
>>>>>>> b88a5de8f7c78e091ae9352ba2b77ca50097c12d

      AlumNet.execute('render:admin:banner:submenu', undefined, 0)

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(bannerTable)
      layoutView.create.show(createBanner)


