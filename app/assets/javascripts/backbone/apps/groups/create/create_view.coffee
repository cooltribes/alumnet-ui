@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->

  class Create.GroupForm extends Marionette.ItemView
    template: 'groups/create/templates/form'

    initialize: (options)->
      @user = options.user
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

    templateHelpers: ->
      userIsAdmin: @user.isAlumnetAdmin()

    ui:
      'selectCountries':'.js-countries'
      'selectCities':'.js-cities'
      'selectJoinProcess': '#join-process'

    events:
      'click button.js-submit': 'submitClicked'
      'change #group-cover': 'previewImage'
      'change .js-countries': 'setCities'
      'change #group-type': 'changedGroupType'

    changedGroupType: (e)->
      select = $(e.currentTarget)
      @ui.selectJoinProcess.html(@joinOptionsString(select.val()))

    joinOptionsString: (option)->
      if option == "1"
        '<option value="1">All Members can invite, but the admins approved</option>
        <option value="2">Only the admins can invite</option>'
      else if option == "2"
        '<option value="2">Only the admins can invite</option>'
      else
        '<option value="0">All Members can invite</option>
        <option value="1">All Members can invite, but the admins approved</option>
        <option value="2">Only the admins can invite</option>'

    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#group-cover')
      formData.append('cover', file[0].files[0])
      @model.set(data)
      @trigger 'form:submit', @model, formData

    previewImage: (e)->
      input = @.$('#group-cover')
      preview = @.$('#preview-cover')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    setCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
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

    onRender: ->
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []
      data = CountryList.toSelect2()
      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: data

