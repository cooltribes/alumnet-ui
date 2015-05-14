@AlumNet.module 'GroupsApp.BanerList', (BanerList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class BanerList.Layout extends Marionette.LayoutView
    template: 'groups/baner/templates/layout'
    className: 'container'
    regions:
      table: '#list-region'
      create: '#create-region'

  #Vista para crear un baner
  class BanerList.CreateView extends Marionette.ItemView
    template: 'groups/baner/templates/createBaner'
    className: 'col-md-8 col-md-offset-2'
    
    events:
      'change #BanerImg': 'previewImage'
      'click #js-btnNewBanner':'showBoxNewBanner'
      'click #js-cancelNewBanner':'showBoxNewBanner'

    previewImage: (e)->
      input = @.$('#group-cover')
      preview = @.$('#preview-baner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    showBoxNewBanner:(e) ->
      e.preventDefault()
      $("#js-newBanner").slideToggle("slow")
      $("#js-btnNewBanner").toggle("slow") 

  #Vista para un baner
  class BanerList.BanerView extends Marionette.ItemView
    template: 'groups/baner/templates/baner'


  #Vista la lista de baners
  class BanerList.BanerTable extends Marionette.CompositeView
    template: 'groups/baner/templates/baner_table'
    className: 'col-md-8 col-md-offset-2'
    childView: BanerList.BanerView
    childViewContainer: "#baners-list"

    events:
      'click #js-editBanner':'showBoxEditBanner'
      'click #js-cancelEditBanner':'showBoxEditBanner'
    
    showBoxEditBanner:(e)->
      e.preventDefault()
      $("#js-boxEditBanner").slideToggle("slow")
      $("#js-editImgBanner").toggle()