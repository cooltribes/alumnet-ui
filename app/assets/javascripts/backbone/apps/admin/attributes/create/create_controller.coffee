@AlumNet.module 'AdminApp.AttributesCreate', (AttributesCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class AttributesCreate.Controller
    create: ->
      layoutView = new AttributesCreate.Layout
      attribute = new AlumNet.Entities.Attribute
      createForm = new AttributesCreate.CreateForm
        model: attribute

      AlumNet.mainRegion.show(layoutView)
      AlumNet.execute 'show:footer'
      layoutView.table.show(createForm)
      AlumNet.execute('render:admin:attributes:submenu', undefined, 1)