@AlumNet.module 'GroupsApp.SubGroups', (SubGroups, @AlumNet, Backbone, Marionette, $, _) ->
  class SubGroups.EmptyView extends Marionette.ItemView
    template: 'groups/subgroups/templates/empty'

  class SubGroups.GroupForm extends Marionette.ItemView
    template: 'groups/subgroups/templates/form'

    initialize:(options)->
      @group = options.group
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
      group_name: @group.get('name')
      userIsAdmin: @user.isAlumnetAdmin()
      groupCanHaveOfficialSubgroup: @group.canHaveOfficialSubgroup()

    ui:
      'selectCountries':'.js-countries'
      'selectCities':'.js-cities'
      'selectJoinProcess': '#join-process'
      'groupDescription': '#group-description'


    events:
      'click a.js-submit': 'submitClicked'
      'click a.js-cancel': 'cancelClicked'
      'change #group-cover': 'previewImage'
      'change .js-countries': 'setCities'
      'change #group-type': 'changedGroupType'
      'click #js-file-groups': 'uploadFile'

    changedGroupType: (e)->
      select = $(e.currentTarget)
      @ui.selectJoinProcess.html(@joinOptionsString(select.val()))

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

    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#group-cover')
      formData.append('cover', file[0].files[0])
      ##send pictures id as array. This is formData way
      _.forEach @picture_ids, (value)->
        formData.append('picture_ids[]', value)
      @model.set(data)
      @trigger 'form:submit', @model, formData

    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger 'groups:subgroups', @group.id

    previewImage: (e)->
      input = @.$('#group-cover')
      preview = @.$('#preview-cover')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

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

  class SubGroups.GroupView extends Marionette.ItemView
    template: 'groups/subgroups/templates/group'
    className: 'col-md-4 col-sm-6 col-xs-12'
    events:
      'click .js-join':'sendJoin'
    ui:
      'groupCard': '.groupCard__atribute__container'
      'groupCardOdd': '.groupCard__atribute__container--odd'

    sendJoin: (e)->
      e.preventDefault()
      @trigger 'join'

    onRender: ->
      @ui.groupCard.tooltip()
      @ui.groupCardOdd.tooltip()

  class SubGroups.GroupsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'groups/subgroups/templates/groups_container'
    childView: SubGroups.GroupView
    emptyView: SubGroups.EmptyView
    childViewContainer: ".main-groups-area"

    templateHelpers: ->
      userCanCreateSubGroup: @model.canDo('create_subgroup')
