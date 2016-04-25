@AlumNet.module 'AdminApp.ProductCreate', (ProductCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductCreate.Layout extends Marionette.LayoutView
    template: 'admin/products/create/templates/layout'

    regions:
      content_region: "#region_content"

    events:
      'click .optionMenu': 'goOption'

    initialize: ->
      @tab = "General"
  
    goOption: (e)->  
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @tab = valueClick
      @trigger "navigate:menu", valueClick
      $("#step").html(@tab)
      $('#active').removeClass('active')

    templateHelpers: ->
      step: @tab

  class ProductCreate.General extends Marionette.LayoutView
    template: 'admin/products/create/templates/general'

    ui:
      'createButton': '.js-create'

    events: 
      'click #js-span-file' : 'inputFile'
      'change #product_image': 'previewLogo'
      'click .js-create': 'createClicked'

    previewLogo: (e)->
      input = @.$('#product_image')
      preview = @.$('#preview_image')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    inputFile: (e)->
      e.preventDefault()
      $('#product_image').click()

    initialize: (options)->
      @model = options.model
      $(window).scroll(()->
        if ($(this).scrollTop() > 260) 
          $('#smoothScroll').addClass("fixed").fadeIn()
        else $('#smoothScroll').removeClass("fixed"))

    onRender: ->
      @$("#status_#{@model.get('status')}").attr('checked', 'checked')
      @$("#highlight_#{@model.get('highlight')}").attr('checked', 'checked')

    templateHelpers: ->
      model = @model
      productImage: ->
        if model.get('image')
          model.get('image').image.card.url

    createClicked: (e)->
      @ui.createButton.attr("disabled", "disabled")
      e.preventDefault()

      view = @
      model = @model
      console.log 'model'
      console.log model

      #Guardar con imagen
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#product_image')
      formData.append('image', file[0].files[0])

      options_for_save =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: (model, response, options)->
          $.growl.notice({ message: "Product successfully created" })
          AlumNet.trigger "admin:products:update", model.id
      model.save(formData, options_for_save)

  class ProductCreate.Prices extends ProductCreate.General
    template: 'admin/products/create/templates/prices'

  class ProductCreate.Category extends Marionette.ItemView
    template: 'admin/products/create/templates/_category'

  class ProductCreate.Categories extends ProductCreate.General
    template: 'admin/products/create/templates/categories'
    childView: ProductCreate.Category
    childViewContainer: "#list-categories"

  class ProductCreate.Attributes extends ProductCreate.General
    template: 'admin/products/create/templates/attributes'

    onShow: ->
      $('.js-multiselect').multiselect({
        right: '#js_multiselect_to_1'
        rightAll: '#js_right_All_1'
        rightSelected: '#js_right_Selected_1'
        leftSelected: '#js_left_Selected_1'
        leftAll: '#js_left_All_1'
      })