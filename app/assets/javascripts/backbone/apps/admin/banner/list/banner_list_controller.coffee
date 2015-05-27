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
      layoutView.table.show(bannerTable)
      layoutView.create.show(createBanner)


      #body.on 'banner:update',(model, newValue) ->
      #      model.save({
      #        description: newValue,
      #        })

      