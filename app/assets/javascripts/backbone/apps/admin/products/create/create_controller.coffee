@AlumNet.module 'AdminApp.ProductCreate', (ProductCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductCreate.Controller
    showLayoutCreate: ->
      @layoutView = new ProductCreate.Layout
      AlumNet.mainRegion.show(@layoutView)
      @showGeneral()

      self = @
      @layoutView.on "navigate:menu", (valueClick)->
        self.showRegionMenu(valueClick)

    showGeneral: ->
      view = new ProductCreate.General
      @layoutView.content_region.show(view)

    showPrices: ->
      view = new ProductCreate.Prices
      @layoutView.content_region.show(view)

    showCategories: ->
      view = new ProductCreate.Categories
      @layoutView.content_region.show(view)

    showAttributes: ->
      view = new ProductCreate.Attributes
      @layoutView.content_region.show(view)

    showRegionMenu: (valueClick) ->
      self = @
      switch valueClick
        when "General"
          self.showGeneral()
        when "Prices"
          self.showPrices()
        when "Categories"
          self.showCategories()
        when "Attributes"
          self.showAttributes()
         