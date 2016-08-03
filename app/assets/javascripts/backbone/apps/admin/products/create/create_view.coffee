@AlumNet.module 'AdminApp.ProductCreate', (ProductCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductCreate.Layout extends Marionette.LayoutView
    template: 'admin/products/create/templates/layout'

    regions:
      content_region: "#region_content"

    events:
      'click .optionMenu': 'goOption'

    initialize: (options)->
      console.log 'initialize'
      console.log options
      @tab = 'General'
      @product = options.product

    onRender: ->
      $('body,html').animate({scrollTop: 0}, 600);
  
    goOption: (e)->  
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @tab = valueClick
      @trigger "navigate:menu", valueClick, @product
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
      'click .js-create': 'submitForm'
      'click .js-continue': 'submitForm'
      'click .js-clear': 'clearForm'

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

    onRender: ->
      @$("#status_#{@model.get('status')}").attr('checked', 'checked')
      @$("#highlight_#{@model.get('highlight')}").attr('checked', 'checked')

    templateHelpers: ->
      model = @model
      productImage: ->
        if model.get('image')
          model.get('image').image.card.url

    submitForm: (e)->
      #@ui.createButton.attr("disabled", "disabled")
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
          if $(e.currentTarget).data('action') == 'continue'
            AlumNet.trigger "admin:products:prices", model.id
          else
            AlumNet.trigger "admin:products:update", model.id

      model.set(data)
      model.save(formData, options_for_save)

    clearForm: (e)->
      e.preventDefault()
      $(':input').not(':button, :submit, :reset, :hidden, :checkbox, :radio, select').val('')

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
      'click .js-continue': 'saveClicked'
      'change @ui.taxRule': 'validateTaxRule'
      'change @ui.discountType': 'validateDiscountType'
      'keyup @ui.salePrice': 'calculatePrices'
      'keyup @ui.taxValue': 'calculatePrices'
      'keyup @ui.discountValue': 'calculatePrices'
      'click .js-clear': 'clearForm'

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
            if $(e.currentTarget).data('action') == 'continue'
              AlumNet.trigger "admin:products:categories", model.id
            else
              AlumNet.trigger "admin:products:prices", model.id
            
        model.save(formData, options_for_save)
      else
        $.growl.error({ message: "Invalid parameters" })

    clearForm: (e)->
      e.preventDefault()
      $(':input').not(':button, :submit, :reset, :hidden, :checkbox, :radio, select').val('')
      $('select').find('option:eq(0)').prop('selected', true)
      @ui.discountValue.attr('disabled', 'disabled')
      @ui.discountValue.val('0')
      @ui.taxValue.attr('disabled', 'disabled')
      @ui.taxValue.val('0')
      @ui.totalPrice.val('0')

  class ProductCreate.Category extends Marionette.ItemView
    template: 'admin/products/create/templates/_category'

    events:
      'click .js-category': 'saveCategory'

    initialize: (options)->
      @product = options.product
      @product_categories = options.product_categories

    templateHelpers: ->
      product_categories = @product_categories
      productCategoryExists: (category_id)->
        if product_categories.findWhere({category_id: category_id})
          'checked'

    saveCategory: (e)->
      if e.currentTarget.checked
        product_category = new AlumNet.Entities.ProductCategory
        product_category.set({category_id: e.currentTarget.value, product_id: @product.id})
        product_category.save()
      else
        product_category = @product_categories.findWhere({category_id: parseInt(e.currentTarget.value), product_id: @product.id})
        product_category.destroy()

  class ProductCreate.Categories extends Marionette.CompositeView
    template: 'admin/products/create/templates/categories'
    childView: ProductCreate.Category
    childViewContainer: "#list-categories"
    childViewOptions: (model)->
      { product: this.options.model, product_categories: this.options.product_categories }

    ui:
      'saveButton': '.js-save'
      'continueButton': '.js-continue'
      
    events:
      'click .js-save': 'saveClicked'
      'click .js-continue': 'saveClicked'
      'click .js-clear': 'clearForm'

    initialize: (options)->
      @product_categories = options.product_categories
      @model = options.model

      AlumNet.setTitle('Product categories')
      $(window).scroll(()->
        if ($(this).scrollTop() > 260) 
          $('#smoothScroll').addClass("fixed").fadeIn()
        else $('#smoothScroll').removeClass("fixed"))

    templateHelpers: ->
      subcategories: @model.get('children')

    saveClicked: (e)->
      e.preventDefault()
      if $(':input:checkbox:checked').length > 0
        $.growl.notice({ message: "Product successfully saved!" })
        if $(e.currentTarget).data('action') == 'continue'
          AlumNet.trigger "admin:products:attributes", @model.id
      else
        $.growl.error({ message: "Please select at least one category" })

    clearForm: (e)->
      e.preventDefault()
      self = @
      $(':input:checkbox:checked').each (value) ->
        product_category = self.product_categories.findWhere({category_id: parseInt($(this).val()), product_id: self.model.id})
        product_category.destroy()
      $(':input:checkbox:checked').removeAttr('checked')

  class ProductCreate.Attribute extends Marionette.ItemView
    template: 'admin/products/create/templates/_attribute'

    events:
      'click .js-attribute': 'attributeClicked'

    initialize: (options)->
      @model = options.model
      @product = options.product
      @product_attributes = options.product_attributes

    templateHelpers: ->
      product_attribute = @product_attributes.findWhere({characteristic_id: @model.id})
      productAttributeChecked: (attribute_id)->
        if product_attribute
          'checked'
      productAttributeDisabled: (attribute_id)->
        if not product_attribute
          'disabled'
      productAttributeValue: (attribute_id)->
        if product_attribute
          product_attribute.get('value')
        else
          ''

    attributeClicked: (e)->
      if e.currentTarget.checked
        $('#attribute_value_'+$(e.currentTarget).val()).removeAttr('disabled')
        $('#attribute_value_'+$(e.currentTarget).val()).focus()
      else
        $('#attribute_value_'+$(e.currentTarget).val()).attr('disabled', 'disabled')
        $('#attribute_value_'+$(e.currentTarget).val()).val('')
        product_attribute = @product_attributes.findWhere({characteristic_id: parseInt(e.currentTarget.value), product_id: @product.id})
        product_attribute.destroy()

  class ProductCreate.Attributes extends Marionette.CompositeView
    template: 'admin/products/create/templates/attributes'
    childView: ProductCreate.Attribute
    childViewContainer: "#list-attributes"
    childViewOptions: (model)->
      { product: this.options.model, product_attributes: this.options.product_attributes }

    events:
      'click .js-save': 'saveClicked'
      'click .js-continue': 'saveClicked'
      'click .js-clear': 'clearForm'

    initialize: (options)->
      AlumNet.setTitle('Product attributes')
      $(window).scroll(()->
        if ($(this).scrollTop() > 260) 
          $('#smoothScroll').addClass("fixed").fadeIn()
        else $('#smoothScroll').removeClass("fixed"))

    saveClicked: (e)->
      e.preventDefault()
      self = @
      $('.js-attribute:checked').each (value) ->
        product_attribute = new AlumNet.Entities.ProductAttribute
        product_attribute.set({characteristic_id: $(this).val(), product_id: self.model.id, value: $('#attribute_value_'+$(this).val()).val()})
        product_attribute.save()
      $.growl.notice({ message: "Product successfully saved!" })
      AlumNet.trigger "admin:products"