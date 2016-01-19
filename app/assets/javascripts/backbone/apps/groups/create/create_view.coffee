@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->

  class Create.GroupForm extends Marionette.ItemView
    template: 'groups/create/templates/form'

    initialize: (options)->
      @user = options.user
      @picture_ids = []
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
      'mailchimpCheckbox': '#mailchimp'
      'mailchimpCheckboxContainer': '#mailchimp-check-container'
      'mailchimpParameters': '#mailchimp-parameters-container'
      'groupDescription': '#group-description'

    events:
      'click a.js-submit': 'submitClicked'
      'click a.js-cancel': 'cancelClicked'
      'change #group-cover': 'previewImage'
      'change .js-countries': 'setCities'
      'change #group-type': 'changedGroupType'
      'change #official': 'showMailchimpCheckbox'
      'change #mailchimp': 'showMailchimpParamaters'
      'click #js-file-groups': 'uploadFile'

    showMailchimpCheckbox: (e)->
      select = $(e.currentTarget)
      if(select.val() == "1")
        @ui.mailchimpCheckboxContainer.removeClass('hide')
      else
        @ui.mailchimpCheckboxContainer.addClass('hide')

    showMailchimpParamaters: (e)->
      check = $(e.currentTarget)
      console.log(check.is(':checked'))
      if(check.is(':checked'))
        @ui.mailchimpParameters.removeClass('hide')
      else
        @ui.mailchimpParameters.addClass('hide')

    changedGroupType: (e)->
      select = $(e.currentTarget)
      @ui.selectJoinProcess.html(@joinOptionsString(select.val()))
      $("#js-message-group").html(@changeMessage(select.val()))


    changeMessage: (option)->
      if option=="closed"
        'All Members can invite, but the admins approved. The group can be found in group searches.'
      else if option == "secret"
        'Only the admins can invite. The group can not be found in group searches.'
      else 'Any member can join and watch the published messages even if the user is not part of the group. The group can be found in group searches.'

    joinOptionsString: (option)->
      if option == "closed"
        '<option value="1">All Members can invite, but the admins approved</option>
        <option value="2">Only the admins can invite</option>'
      else if option == "secret"
        '<option value="2">Only the admins can invite</option>'
      else
        '<option value="0">All Members can invite</option>
        <option value="1">All Members can invite, but the admins approved</option>
        <option value="2">Only the admins can invite</option>'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      $(e.currentTarget).removeClass('js-submit')
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      data.description = @ui.groupDescription.summernote('code')
      file = @$('#group-cover')
      formData.append('cover', file[0].files[0])
      ##send pictures id as array. This is formData way
      _.forEach @picture_ids, (value)->
        formData.append('picture_ids[]', value)
      @model.set(data)
      @trigger 'form:submit', @model, formData

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger 'groups:discover'

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
      view = @
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []
      data = CountryList.toSelect2()
      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: data
      @ui.groupDescription.summernote
        height: 200
        callbacks:
          onImageUpload: (files)->
            view.sendDescriptionImage(files[0])

    sendDescriptionImage: (file)->
      view = @
      data = new FormData();
      data.append("file", file);
      Backbone.ajax
        data: data
        type: "POST"
        url: AlumNet.api_endpoint + "/pictures"
        cache: false
        contentType: false
        processData: false
        success: (data) ->
          view.picture_ids.push(data.id)
          view.ui.groupDescription.summernote('insertImage', data.picture.original)

    uploadFile: (e)->
      e.preventDefault()
      $('#group-cover').click()
