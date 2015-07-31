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
    className: 'col-md-8 col-md-offset-2'

    initialize: (options)->
      @collection = options.collection
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    events:
      'click #js-btnNewBanner':'showBoxNewBanner'
      'click #js-cancelNewBanner':'showBoxNewBanner'
      'change #BannerImg': 'previewImage'
      'click #js-addBanner': 'addBanner'


    showBoxNewBanner:(e) ->
      e.preventDefault()
      $("#js-newBanner").slideToggle("slow")
      $("#js-btnNewBanner").toggle("slow") 

    
    addBanner: (e)->
      e.preventDefault()
      view = @
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#BannerImg')
      formData.append('picture', file[0].files[0])
      console.log data
      
      @model.set(data)

      if @model.isValid(true)
        options_for_save =
          wait: true
          contentType: false
          processData: false
          data: formData
          success: (model, response, options)->
            view.collection.add(model)
        @model.save(formData, options_for_save)
        @render()
    

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

    ui:
      'buttonUp': '#js-move-up'
      'buttonDown':'#js-move-down'
      'editBanner':'#js-edit-banner'      
      'upload':'.uploadLabel' 
      'update':'.js-update'

    events:
      'click #js-deleteBanner': 'deleteBanner'
      'click #js-move-up': 'moveUp'
      'click #js-move-down': 'moveDown'
      'click @ui.editBanner': 'editClicked'
      'click @ui.update':'updateClicked' 
      'change #BannerImg': 'previewImage'
      'click #js-editBanner':'showBoxEditBanner'
      'click #js-cancelEditBanner':'hideBoxEditBanner'
    
    showBoxEditBanner:(e)->
      e.preventDefault()
      $(e.currentTarget).parent().parent().siblings("#js-boxEditBanner").slideToggle("slow")
      $(e.currentTarget).parent().siblings("label").slideToggle("slow")

    hideBoxEditBanner:(e)->
      e.preventDefault()
      $(e.currentTarget).parent().parent('#js-boxEditBanner').slideToggle("slow")
      $(e.currentTarget).parent().parent().siblings().children("label").slideToggle("slow")

    initialize: (options)->      
      @collection = options.collection
      $(@ui.upload).hide()
      $(@ui.update).hide()
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')
              
    editClicked: (e)->
      e.preventDefault()
      console.log "edit"
      $("[name='title']").prop('disabled', false)
      $("[name='link']").prop('disabled', false)
      $("[name='description']").prop('disabled', false)
      $(@ui.upload).show()
      $(@ui.update).show()

    deleteBanner: (e)->
      e.preventDefault()
      e.stopPropagation()
      resp = confirm("Are you sure?")
      if resp
        @model.destroy()
        
    moveUp: (e)->
      e.preventDefault()
      e.stopPropagation()
      indexToUp = @model.collection.indexOf(@model)
      above = parseInt(indexToUp)
      if indexToUp > 0 
        @trigger 'Swap:Up',indexToUp, indexToUp+1, above
      
    moveDown: (e)->
      e.preventDefault()
      e.stopPropagation()
      indexToDown = @model.collection.indexOf(@model)
      @trigger 'Swap:Down', indexToDown, indexToDown+1, indexToDown+2

    updateClicked: (e)->
      e.preventDefault()
      view = @
      model = @model
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#BannerImg')
      formData.append('picture', file[0].files[0])
      @model.set(data)
      if @model.isValid(true)
        options_for_save =
          wait: true
          contentType: false
          processData: false
          data: formData
          success: (model, response, options)->          
            view.model.set(formData)  
        @model.save(formData, options_for_save)        
        @model.trigger 'banner:count'
        $("[name='title']").prop('disabled', true)
        $("[name='link']").prop('disabled', true)
        $("[name='description']").prop('disabled', true)
        $(@ui.upload).hide()
        $(@ui.update).hide()
 
  
    previewImage: (e)->
      input = @.$('#BannerImg')
      preview = @.$('#preview-banner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])  


  #Vista para lista de banners
  class BannerList.BannerTable extends Marionette.CompositeView
    template: 'admin/banner/list/templates/banner_table'
    className: 'col-md-8 col-md-offset-2'
    childView: BannerList.BannerView
    childViewContainer: "#banners-list"

    

      
    initialize: (options)->
      document.title= 'AlumNet - Banners Management'      
      @collection.each (model)->     
        attrs = { order: model.get('order')}   
         
    onChildviewSwapUp: (bannerToUp, currentIndex, indexAbove)->
      indexAbove = indexAbove-2
      bannerAbove = @collection.at(indexAbove)
      bannerAbove = @collection.remove(bannerAbove) 
      currentBanner = @collection.remove(bannerToUp) 
      @collection.add(currentBanner, {at: indexAbove}) 
      @collection.add(bannerAbove, at: currentIndex)
      @trigger 'banner:count'
            
        
    onChildviewSwapDown: (bannerToDown, currentIndex, indexBelow) ->
      bannerBelow = @collection.at(indexBelow)
      bannerBelow = @collection.remove(bannerBelow) 
      currentBanner = @collection.remove(bannerToDown) 
      @collection.add(currentBanner, {at: indexBelow}) 
      @collection.add(bannerBelow, at: currentIndex)
      @trigger 'banner:count'


  class BannerList.CropCoverModal extends Backbone.Modal
    template: 'admin/banner/list/templates/crop_modal'
    cancelEl: '#js-close-btn'

    onShow: ->
      model = @model
      image = @model.get('picture').original 
      options =
        loadPicture: image
        cropUrl: AlumNet.api_endpoint + "/banners/#{@model.id}/cropping"
        onAfterImgCrop: ->
          model.trigger('change:banner')

      cropper = new Croppic('croppic', options)    

###
  class BannerList.Modal extends Backbone.Modal
    template: 'admin/banner/list/templates/upload_modal'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-crop': 'cropClicked'
      'change #BannerImg': 'previewImage'

    initialize: (options)->
      @collection = options.collection
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')
  

    cropClicked: (e)->
      e.preventDefault()
      modal = new BannerList.CropCoverModal
        model: @model
      @destroy()
      $('#js-modal-banner-container').html(modal.render().el)

    previewImage: (e)->
      input = @.$('#BannerImg')
      preview = @.$('#preview-banner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

        
    saveClicked: (e)->
      e.preventDefault()
      view = @
      model = @model
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#BannerImg')
      formData.append('picture', file[0].files[0])
      @model.set(data)
      if @model.isValid(true)
        options_for_save =
          wait: true
          contentType: false
          processData: false
          data: formData
          success: (model, response, options)->
            view.model.set(formData)       
            model.trigger('change:banner', file)
        @model.save(formData, options_for_save)
        @destroy()
###
     

      