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
      console.log @model.get('children')

    showAdmins: (e)->
      e.preventDefault()
      console.log @model.get('admins')

  class Groups.GroupsTable extends Marionette.CompositeView
    template: 'admin/groups/templates/groups_table'
    childView: Groups.GroupView
    childViewContainer: "#groups-table tbody"

  class Groups.ModalEdit extends Backbone.Modal
    template: 'admin/groups/templates/modal_edit'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'change #group-cover': 'previewImage'
      'change .js-countries': 'setCities'
      'change #group-type': 'changedGroupType'

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
      @model.set(data)
      @model.save data,
        success: ->
          model.trigger 'render:view'
          modal.destroy()

