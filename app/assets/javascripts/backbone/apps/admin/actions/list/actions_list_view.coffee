@AlumNet.module 'AdminApp.ActionsList', (ActionsList, @AlumNet, Backbone, Marionette, $, _) ->
  class ActionsList.Layout extends Marionette.LayoutView
    template: 'admin/actions/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  # class GroupsList.SearchView extends Marionette.ItemView
  #   template: 'admin/groups/list/templates/search'

  #   events:
  #     'click .js-search': 'searchCliked'

  #   searchCliked: (e)->
  #     e.preventDefault()
  #     term = @.$('#search_term').val()
  #     @trigger 'search', term


  class ActionsList.ActionView extends Marionette.ItemView
    template: 'admin/actions/list/templates/action'
    tagName: "tr"

    modelEvents:
      "change": "modelChange"

    initialize: ()->
      #view.$("[name=status]")
      #@listenTo(@model, 'render:view', @renderView)

    bindings:
      ".js-name": 
        observe: "name"
        events: ['blur']
      ".js-description": 
        observe: "description"
        events: ['blur']
      ".js-value": 
        observe: "value"
        events: ['blur']
      ".js-status": 
        observe: "status"
        selectOptions:
          collection: [
            value: "inactive"
            label: "inactive"
          ,
            value: "active"
            label: "active"
          ,
          ]

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

    #ui:
      # 'editLink': '.js-edit'
      # 'subGroupsLink': '#js-show-subgroups'

    #events:
      # 'click @ui.editLink': 'editClicked'
      # 'click @ui.subGroupsLink': 'subGroupsClicked'

    # renderView: ->
    #   @render()

    # editClicked: (e)->
    #   e.preventDefault()
    #   modal = new GroupsList.ModalEdit
    #     model: @model #group
    #   $('#container-modal-edit').html(modal.render().el)

    # subGroupsClicked: (e)->
    #   e.preventDefault()
    #   subgroups = AlumNet.request('subgroups:entities:admin', @model.id, {})
    #   @trigger 'subgroups:show', subgroups

  class ActionsList.ActionsTable extends Marionette.CompositeView
    template: 'admin/actions/list/templates/actions_table'
    childView: ActionsList.ActionView
    childViewContainer: "#actions-table tbody"
    
    #initialize: (options)->
      #@linksGroups = options.linksGroups

    #templateHelpers: ->
      #links: @linksGroups

    #events:
      # 'click #js-groups-home': 'groupsHome'
      # 'click .js-groups-bc': 'groupsBreadCrumb'

  # class GroupsList.ModalEdit extends Backbone.Modal
  #   template: 'admin/groups/list/templates/modal_edit'
  #   cancelEl: '.js-modal-close'

  #   events:
  #     'click .js-modal-save': 'saveClicked'
  #     'click .js-modal-delete': 'deleteClicked'
  #     'change #group-cover': 'previewImage'
  #     'change .js-countries': 'selectCities'
  #     'change #group-type': 'changedGroupType'

  #   deleteClicked: (e)->
  #     e.preventDefault()
  #     resp = confirm("Are you sure?")
  #     if resp
  #       @model.destroy()
  #       @destroy()

  #   selectCities: (e)->
  #     @.$('.js-cities').val('')
  #     @setSelect2Cities(e.val, false)

  #   setSelect2Cities: (val, initialValue)->
  #     url = AlumNet.api_endpoint + '/countries/' + val + '/cities'
  #     options =
  #       placeholder: "Select a City"
  #       minimumInputLength: 2
  #       ajax:
  #         url: url
  #         dataType: 'json'
  #         data: (term)->
  #           q:
  #             name_cont: term
  #         results: (data, page) ->
  #           results:
  #             data
  #       formatResult: (data)->
  #         data.name
  #       formatSelection: (data)->
  #         data.name
  #       initSelection: (element, callback)->
  #         callback(initialValue) if initialValue
  #     @.$('.js-cities').select2 options


  #   setSelect2Groups: (initialValue)->
  #     url = AlumNet.api_endpoint + '/admin/groups'
  #     view = @
  #     options =
  #       placeholder: "Select a Group"
  #       minimumInputLength: 2
  #       allowClear: true
  #       ajax:
  #         url: url
  #         dataType: 'json'
  #         data: (term)->
  #           q = {}
  #           official = view.$('#official').val()
  #           if official == "1"
  #             return q:
  #               name_cont: term
  #               official_eq: official
  #           else
  #             return q:
  #               name_cont: term

  #         results: (data, page) ->
  #           results:
  #             data
  #       formatResult: (data)->
  #         data.name
  #       formatSelection: (data)->
  #         data.name
  #       initSelection: (element, callback)->
  #         callback(initialValue) if initialValue
  #     @.$('.js-groups').select2 options


  #   changedGroupType: (e)->
  #     select = $(e.currentTarget)
  #     $('#join-process').html(@joinOptionsString(select.val()))

  #   joinOptionsString: (option)->
  #     if option == "closed"
  #       '<option value="1">All Members can invite, but the admins approved</option>
  #       <option value="2">Only the admins can invite</option>'
  #     else if option == "secret"
  #       '<option value="2">Only the admins can invite</option>'
  #     else
  #       '<option value="0">All Members can invite</option>
  #       <option value="1">All Members can invite, but the admins approved</option>
  #       <option value="2">Only the admins can invite</option>'

  #   saveClicked:(e)->
  #     e.preventDefault()
  #     modal = @
  #     model = @model
  #     rawData = Backbone.Syphon.serialize(modal)
  #     @model.urlRoot = AlumNet.api_endpoint + '/admin/groups'
  #     data = rawData
  #     @model.save data,
  #       success: ->
  #         model.trigger 'render:view'
  #         modal.destroy()

  #   onRender: ->
  #     data = CountryList.toSelect2()
  #     country = @model.get('country')
  #     city = @model.get('city')
  #     initialCity = { id: city.value, name: city.text }
  #     parent = @model.get('parent')

  #     @.$('.js-countries').select2
  #       placeholder: "Select a Country"
  #       data: data

  #     @.$('.js-countries').select2('val', country.value)
  #     @setSelect2Cities(country.value, initialCity)
  #     @setSelect2Groups(parent)