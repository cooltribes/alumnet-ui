@AlumNet.module 'CompaniesApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Form extends Marionette.ItemView
    template: 'companies/create/templates/form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          view.clearErrors(attr)
        invalid: (view, attr, error, selector) ->         
          view.addErrors(attr, error)

    templateHelpers: ->
      model = @model
      city_helper: if @model.get('city') then @model.get('city').value
      sizes_options: (item)->
        model.sizes_options(item)

    ui:
      'cancelLink': '.js-cancel'
      'submitLink': '.js-submit'
      'selectSectors': '#sectors'
      'selectSizes': '#size'
      'selectCountries': '#country_id'
      'selectCities': '#city_id'

    events:
      'click @ui.cancelLink': 'cancelClicked'
      'click @ui.submitLink': 'submitClicked'
      'change @ui.selectCountries': 'setCities'
      'change #logo': 'previewLogo'

    onRender: ->
      countries = CountryList.toSelect2()
      @fillSelectSectors()
      @ui.selectSizes.select2()
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []
      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: countries

      ## set initial value
      unless @model.isNew()
        @ui.selectCountries.select2('val', @model.get('country').value)
        @setSelectCities(@model.get('country').value)

    fillSelectSectors: (initialValue)->
      $select = @ui.selectSectors
      Backbone.ajax
        url: AlumNet.api_endpoint + '/sectors'
        success: (data)->
          $select.select2
            placeholder: "Select a Sector"
            data: { results: data, text: "name" }
      if initialValue
        $select.select2("data", initialValue)

    cancelClicked: (e)->
      e.preventDefault()

    submitClicked: (e)->
      @ui.submitLink.add(@ui.cancelLink).attr("disabled", "disabled")
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.set(data)
      dataForm = @processData(data)
      dataForm.append('logo', @$('#logo')[0].files[0])
      if @model.isValid(true)
        @model.save {},
          contentType: false
          processData: false
          data: dataForm
          success: (model)->
            $.growl.notice({ message: "Company successfully created" })            
            AlumNet.trigger "company:about", model.id

          error: (model, response)->
            errors = response.responseJSON
            _.each errors, (value, key, list)->
              view.clearErrors(key)
              view.addErrors(key, value[0])
            # @ui.submitLink.add(@ui.cancelLink).removeAttr("disabled")          


      # @ui.submitLink.add(@ui.cancelLink).removeAttr("disabled")        

    processData: (data)->
      formData = new FormData()
      _.each data, (value, key, list)->
        formData.append(key, value)
      formData

    clearErrors: (attr)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-group')
      $group.removeClass('has-error')
      $group.find('.help-block').html('').addClass('hidden')

    addErrors: (attr, error)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-group')
      $group.addClass('has-error')
      $group.find('.help-block').html(error).removeClass('hidden')
      @ui.submitLink.add(@ui.cancelLink).removeAttr("disabled")          

    setCities: (e)->
      @setSelectCities(e.val)

    setSelectCities: (country_id)->
      if @model.get('city')
        initialValue = { id: @model.get('city').value, name: @model.get('city').text }
      else
        initialValue = false

      url = AlumNet.api_endpoint + '/countries/' + country_id + '/cities'
      @ui.selectCities.select2
        placeholder: "Select a City"
        minimumInputLength: 2
        ajax:
          url: url
          dataType: 'json'
          data: (term)->
            q:
              name_cont: term
          results: (data, page) ->
            results:
              data
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name
        initSelection: (element, callback)->
          callback(initialValue) if initialValue

    previewLogo: (e)->
      input = @.$('#logo')
      preview = @.$('#preview-logo')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])
