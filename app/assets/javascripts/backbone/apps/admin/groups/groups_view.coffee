@AlumNet.module 'AdminApp.Groups', (Groups, @AlumNet, Backbone, Marionette, $, _) ->
  class Groups.Layout extends Marionette.LayoutView
    template: 'admin/groups/templates/layout'
    className: 'container'
    regions:
      search: '#search-region'
      table: '#table-region'

  class Groups.GroupView extends Marionette.ItemView
    template: 'admin/groups/templates/group'
    tagName: "tr"

    initialize: ->
      @listenTo(@model, 'render:view', @renderView)

    templateHelpers: ->
      model = @model
      getLocation: ->
        country = model.get('country').text
        city = model.get('city').text
        array = []
        array.push(country) unless country == ""
        array.push(city) unless city == ""
        array.join(", ")
      getSubgroupsCount: ->
        model.get('children').length
      getAlumniCount: ->
        model.get('members').length
      getAdminsCount: ->
        model.get('admins').length
      getParentName: ->
        parent = model.get('parent')
        if parent then parent.name else "none"

    ui:
      'editLink': '.js-edit'
      'subGroupsLink': '#js-show-subgroups'
      'AdminsTd': '.js-show-admins'

    events:
      'click @ui.editLink': 'editClicked'
      'click @ui.subGroupsLink': 'subGroupsClicked'
      'hover @adminsTd': 'showAdmins'

    renderView: ->
      @render()

    editClicked: (e)->
      e.preventDefault()
      modal = new Groups.ModalEdit
        model: @model #group
      $('#container-modal-edit').html(modal.render().el)

    subGroupsClicked: (e)->
      e.preventDefault()
      subgroups = AlumNet.request('subgroups:entities:admin', @model.id, {})
      @trigger 'subgroups:show', subgroups

    showAdmins: (e)->
      e.preventDefault()
      console.log @model.get('admins')

  class Groups.GroupsTable extends Marionette.CompositeView
    template: 'admin/groups/templates/groups_table'
    childView: Groups.GroupView
    childViewContainer: "#groups-table tbody"
    initialize: (options)->
      @linksGroups = options.linksGroups

    templateHelpers: ->
      links: @linksGroups

    events:
      'click #js-groups-home': 'groupsHome'
      'click .js-groups-bc': 'groupsBreadCrumb'

    groupsBreadCrumb: (e)->
      e.preventDefault()
      link = $(e.currentTarget)
      group_id = link.data('group-id')
      index = link.data('index')
      subgroups = AlumNet.request('subgroups:entities:admin', group_id, {})
      @trigger 'groups:bc', index, subgroups

    groupsHome: (e)->
      e.preventDefault()
      @trigger 'groups:home'

  class Groups.ModalEdit extends Backbone.Modal
    template: 'admin/groups/templates/modal_edit'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'change #group-cover': 'previewImage'
      'change .js-countries': 'selectCities'
      'change #group-type': 'changedGroupType'

    selectCities: (e)->
      @.$('.js-cities').val('')
      @setSelect2Cities(e.val, false)

    setSelect2Cities: (val, initialValue)->
      url = AlumNet.api_endpoint + '/countries/' + val + '/cities'
      options =
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
      @.$('.js-cities').select2 options


    setSelect2Groups: (initialValue)->
      url = AlumNet.api_endpoint + '/admin/groups'
      view = @
      options =
        placeholder: "Select a Group"
        minimumInputLength: 2
        allowClear: true
        ajax:
          url: url
          dataType: 'json'
          data: (term)->
            q = {}
            official = view.$('#official').val()
            if official == "1"
              return q:
                name_cont: term
                official_eq: official
            else
              return q:
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
      @.$('.js-groups').select2 options


    changedGroupType: (e)->
      select = $(e.currentTarget)
      $('#join-process').html(@joinOptionsString(select.val()))

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

    saveClicked:(e)->
      e.preventDefault()
      modal = @
      model = @model
      rawData = Backbone.Syphon.serialize(modal)
      @model.urlRoot = AlumNet.api_endpoint + '/admin/groups'
      data = rawData
      @model.save data,
        success: ->
          model.trigger 'render:view'
          modal.destroy()

    onRender: ->
      data = CountryList.toSelect2()
      country = @model.get('country')
      city = @model.get('city')
      initialCity = { id: city.value, name: city.text }
      parent = @model.get('parent')

      @.$('.js-countries').select2
        placeholder: "Select a Country"
        data: data

      @.$('.js-countries').select2('val', country.value)
      @setSelect2Cities(country.value, initialCity)
      @setSelect2Groups(parent)