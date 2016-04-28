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
      'continueButton': '.js-continue'

    events: 
      'click #js-span-file' : 'inputFile'
      'change #product_image': 'previewLogo'
      'click .js-create': 'createClicked'
      'click .js-continue': 'continueClicked'

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
      AlumNet.setTitle('Product details')
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
          $.growl.notice({ message: "Product successfully saved!" })
          AlumNet.trigger "admin:products:update", model.id
      model.save(formData, options_for_save)

    continueClicked: (e)->
      @ui.continueButton.attr("disabled", "disabled")
      e.preventDefault()

      view = @
      model = @model

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
          $.growl.notice({ message: "Product successfully saved!" })
          AlumNet.trigger "admin:products:prices", model.id
      model.save(formData, options_for_save)

  class ProductCreate.Prices extends Marionette.ItemView
    template: 'admin/products/create/templates/prices'

    ui:
      'saveButton': '.js-save'
      'continueButton': '.js-continue'
      'taxRule': '#tax_rule'
      'taxValue': '#tax_value'
      'discountType': '#discount_type'
      'discountValue': '#discount_value'
      'salePrice': '#sale_price'
      'totalPrice': '#total_price'

    events:
      'click .js-save': 'saveClicked'
      'click .js-continue': 'continueClicked'
      'change @ui.taxRule': 'validateTaxRule'
      'change @ui.discountType': 'validateDiscountType'
      'keyup @ui.salePrice': 'calculatePrices'
      'keyup @ui.taxValue': 'calculatePrices'
      'keyup @ui.discountValue': 'calculatePrices'

    initialize: (options)->
      AlumNet.setTitle('Product prices')
      $(window).scroll(()->
        if ($(this).scrollTop() > 260) 
          $('#smoothScroll').addClass("fixed").fadeIn()
        else $('#smoothScroll').removeClass("fixed"))
      @validPrices = true

    templateHelpers: ->
      selected: (option, value)->
        if option == value then 'selected' else ''

    onRender: ->
      @validateTaxRule()
      @validateDiscountType()

    validateTaxRule: ->
      if @ui.taxRule.val() == 'no_tax'
        @ui.taxValue.attr('disabled', 'disabled')
        @ui.taxValue.val('0')
        @calculatePrices()
      else
        @ui.taxValue.removeAttr('disabled')

    validateDiscountType: ->
      if @ui.discountType.val() == 'no_discount'
        @ui.discountValue.attr('disabled', 'disabled')
        @ui.discountValue.val('0')
        @calculatePrices()
      else
        @ui.discountValue.removeAttr('disabled')

    calculatePrices: (e)->
      if @validate_prices()
        salePrice = parseFloat(@ui.salePrice.val())
        taxValue = if @ui.taxValue.val() != '' then parseFloat(@ui.taxValue.val()) else 0
        discountValue = if @ui.discountValue.val() != '' then parseFloat(@ui.discountValue.val()) else 0

        totalTax = (salePrice * taxValue) / 100
        totalDiscount = 0
        if @ui.discountType.val() == 'percentage'
          totalDiscount = (salePrice * discountValue) / 100
        if @ui.discountType.val() == 'amount'
          totalDiscount = discountValue

        totalPrice = salePrice + totalTax - totalDiscount
        @ui.totalPrice.val(totalPrice)
      
    validate_prices: ->
      regex  = /^\d*\.?\d*$/
      valid = true
      self = @
      # each price input
      @$('.inputProduct').each (key, value)->
        target = $(value)
        group = $(target.closest('.form-group'))
        # validate not empty
        if target.val() != ''
          # validate number, optional decimal
          if regex.test(target.val())
            group.removeClass("has-error")
            group.find('.help-block').html('').addClass('hidden')
          else
            group.addClass("has-error")
            group.find('.help-block').html('Invalid format').removeClass('hidden')
            self.ui.totalPrice.val('0')
            valid = false
        else
          group.addClass("has-error")
          group.find('.help-block').html('Required field').removeClass('hidden')
          self.ui.totalPrice.val('0')
          valid = false

      valid

    saveClicked: (e)->
      e.preventDefault()
      if @validate_prices()
        @ui.saveButton.attr("disabled", "disabled")
        view = @
        model = @model

        #Guardar con imagen
        formData = new FormData()
        data = Backbone.Syphon.serialize(this)
        _.forEach data, (value, key, list)->
          formData.append(key, value)

        options_for_save =
          wait: true
          contentType: false
          processData: false
          data: formData
          success: (model, response, options)->
            $.growl.notice({ message: "Product successfully saved!" })
            AlumNet.trigger "admin:products:prices", model.id
        model.save(formData, options_for_save)
      else
        $.growl.error({ message: "Invalid parameters" })

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