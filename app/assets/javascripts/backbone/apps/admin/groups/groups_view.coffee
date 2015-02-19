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

    templateHelpers: ->
      model = @model
      getLocation: ->
        model.get('country').text + ", " + model.get('city').text

  class Groups.GroupsTable extends Marionette.CompositeView
    template: 'admin/groups/templates/groups_table'
    childView: Groups.GroupView
    childViewContainer: "#groups-table tbody"
