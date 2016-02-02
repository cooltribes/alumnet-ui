@AlumNet.module 'AdminApp.GroupsList', (GroupsList, @AlumNet, Backbone, Marionette, $, _) ->
  class GroupsList.Layout extends Marionette.LayoutView
    template: 'admin/groups/list/templates/layout'
    className: 'container'
    regions:
      search: '#search-region'
      table: '#table-region'

  class GroupsList.SearchView extends Marionette.ItemView
    template: 'admin/groups/list/templates/search'

    events:
      'click .js-search': 'searchCliked'

    searchCliked: (e)->
      e.preventDefault()
      term = @.$('#search_term').val()
      @trigger 'search', term


  class GroupsList.GroupView extends Marionette.ItemView
    template: 'admin/groups/list/templates/group'
    tagName: "tr"

    initialize: (options)->
      @groupsTable = options.groupsTable
      @listenTo(@model, 'render:view', @renderView)

    templateHelpers: ->
      model = @model
      getLocation: ->
        country = model.get('country').name
        city = model.get('city').name
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

    events:
      'click @ui.editLink': 'editClicked'
      'click @ui.subGroupsLink': 'subGroupsClicked'

    renderView: ->
      @render()

    editClicked: (e)->
      e.preventDefault()
      modal = new GroupsList.ModalEdit
        model: @model #group
      $('#container-modal-edit').html(modal.render().el)

    subGroupsClicked: (e)->
      e.preventDefault()
      subgroups = AlumNet.request('subgroups:entities:admin', @model.id, {})
      groupsTable = @groupsTable
      model = @model
      subgroups.fetch
        success: ->
          groupsTable.linksGroups.push({id: model.id, name: model.get('name')})
          groupsTable.renderView(subgroups)

  class GroupsList.GroupsTable extends Marionette.CompositeView
    template: 'admin/groups/list/templates/groups_table'
    childView: GroupsList.GroupView
    childViewContainer: "#groups-table tbody"

    childViewOptions: ->
      groupsTable: @

    initialize: (options)->
      @linksGroups = options.linksGroups
      AlumNet.setTitle('Groups Management')

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
      view = @
      subgroups.fetch
        success: ->
          view.linksGroups = view.linksGroups.slice(0, (index + 1))
          view.renderView(subgroups)

    groupsHome: (e)->
      e.preventDefault()
      groups = AlumNet.request('group:entities:admin', {})
      view = @
      groups.fetch
        success: ->
          view.linksGroups = []
          view.renderView(groups)

    renderView: (collection)->
      @collection = collection
      @render()

  class GroupsList.ModalEdit extends Backbone.Modal
    template: 'admin/groups/list/templates/modal_edit'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-delete': 'deleteClicked'
      'change #group-cover': 'previewImage'
      'change .js-countries': 'selectCities'
      'change #group-type': 'changedGroupType'

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm("Are you sure?")
      if resp
        @model.destroy()
        @destroy()

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
      initialCity = { id: city.id, name: city.name }
      parent = @model.get('parent')

      @.$('.js-countries').select2
        placeholder: "Select a Country"
        data: data

      @.$('.js-countries').select2('val', country.name)
      @setSelect2Cities(country.name, initialCity)
      @setSelect2Groups(parent)