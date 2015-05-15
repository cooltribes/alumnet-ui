@AlumNet.module 'GroupsApp.BannerList', (BannerList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class BannerList.Layout extends Marionette.LayoutView
    template: 'groups/banner/templates/layout'
    className: 'container'
    regions:
      table: '#list-region'
      create: '#create-region'

  #Vista para crear un banner
  class BannerList.CreateView extends Marionette.ItemView
    template: 'groups/banner/templates/createBanner'
    className: 'col-md-8 col-md-offset-2'
    
    events:
      'change #BannerImg': 'previewImage'
      'click #js-btnNewBanner':'showBoxNewBanner'
      'click #js-cancelNewBanner':'showBoxNewBanner'

    previewImage: (e)->
      input = @.$('#group-cover')
      preview = @.$('#preview-banner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    showBoxNewBanner:(e) ->
      e.preventDefault()
      $("#js-newBanner").slideToggle("slow")
      $("#js-btnNewBanner").toggle("slow") 

  #Vista para un bnaner
  class BannerList.BannerView extends Marionette.ItemView
    template: 'groups/banner/templates/banner'


  #Vista la lista de banners
  class BannerList.BannerTable extends Marionette.CompositeView
    template: 'groups/banner/templates/banner_table'
    className: 'col-md-8 col-md-offset-2'
    childView: BannerList.BannerView
    childViewContainer: "#banners-list"

    events:
      'click #js-editBanner':'showBoxEditBanner'
      'click #js-cancelEditBanner':'showBoxEditBanner'
    
    showBoxEditBanner:(e)->
      e.preventDefault()
      $("#js-boxEditBanner").slideToggle("slow")
      $("#js-editImgBanner").toggle()