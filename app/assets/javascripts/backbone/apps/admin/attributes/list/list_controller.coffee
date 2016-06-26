@AlumNet.module 'AdminApp.AttributesList', (AttributesList, @AlumNet, Backbone, Marionette, $, _) ->
  class AttributesList.Controller
    attributesList: ->
      attributes = AlumNet.request('attributes:entities', {})

      layoutView = new AttributesList.Layout
      attributesTable = new AttributesList.AttributesTable
        collection: attributes

      AlumNet.mainRegion.show(layoutView)
      AlumNet.execute 'show:footer'
      layoutView.table.show(attributesTable)
      AlumNet.execute('render:admin:attributes:submenu', undefined, 0)