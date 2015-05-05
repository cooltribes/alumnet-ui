@AlumNet.module 'AdminApp.BannerList', (BannerList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class BannerList.Layout extends Marionette.LayoutView
    template: 'admin/banner/list/templates/layout'
    className: 'container'
    regions:
      table: '#list-region'
      create: '#create-region'

  #Vista para crear un banner
  class BannerList.CreateView extends Marionette.ItemView
    template: 'admin/banner/list/templates/createBanner'

    events:
      'change #BannerImg': 'previewImage'

    previewImage: (e)->
      input = @.$('#BannerImg')
      preview = @.$('#preview-banner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

  #Vista para un banner
  class BannerList.BannerView extends Marionette.ItemView
    template: 'admin/banner/list/templates/banner'

  #Vista la lista de banners
  class BannerList.BannerTable extends Marionette.CompositeView
    template: 'admin/banner/list/templates/banner_table'
    childView: BannerList.BannerView
    childViewContainer: "#banners-list"
    