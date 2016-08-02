@AlumNet.module 'AdminApp.ProductCreate', (ProductCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductCreate.Controller
    showLayoutCreate: ->
      @layoutView = new ProductCreate.Layout
      AlumNet.mainRegion.show(@layoutView)
      AlumNet.execute 'show:footer'
      @showGeneral()

      self = @
      @layoutView.on "navigate:menu", (valueClick)->
        self.showRegionMenu(valueClick)

    update: (id)->
      product = AlumNet.request('product:find', id)
      @layoutView = new ProductCreate.Layout
      AlumNet.mainRegion.show(@layoutView)
      @showUpdate(product)

      self = @
      @layoutView.on "navigate:menu", (valueClick)->
        self.showRegionMenu(valueClick)

    prices: (id)->
      product = AlumNet.request('product:find', id)
      @layoutView = new ProductCreate.Layout
      AlumNet.mainRegion.show(@layoutView)
      @showPrices(product)

      self = @
      @layoutView.on "navigate:menu", (valueClick)->
        self.showRegionMenu(valueClick)

    categories: (id)->
      product = AlumNet.request('product:find', id)
      @layoutView = new ProductCreate.Layout
      AlumNet.mainRegion.show(@layoutView)
      @showCategories(product)

      self = @
      @layoutView.on "navigate:menu", (valueClick)->
        self.showRegionMenu(valueClick)

    attributes: (id)->
      product = AlumNet.request('product:find', id)
      @layoutView = new ProductCreate.Layout
      AlumNet.mainRegion.show(@layoutView)
      @showAttributes(product)

      self = @
      @layoutView.on "navigate:menu", (valueClick)->
        self.showRegionMenu(valueClick)

    showGeneral: ->
      product = new AlumNet.Entities.Product
      view = new ProductCreate.General
        model: product
      @layoutView.content_region.show(view)

    showUpdate: (product)->
      view = new ProductCreate.General
        model: product
      @layoutView.content_region.show(view)

    showPrices: (product)->
      view = new ProductCreate.Prices
        model: product
      @layoutView.content_region.show(view)

    showCategories: (product)->
      self = @
      categories = AlumNet.request('categories:entities', {q: {father_id_eq: null, 'm': 'or'}})
      product_categories = AlumNet.request('product_categories:entities', {product_id: product.id})
      product_categories.on 'fetch:success', (product_categories_collection)->
        view = new ProductCreate.Categories
          model: product
          collection: categories
          product_categories: product_categories_collection
        self.layoutView.content_region.show(view)

    showAttributes: (product)->
      self = @
      attributes = AlumNet.request('attributes:entities', {})
      product_attributes = AlumNet.request('product_attributes:entities', {product_id: product.id})
      product_attributes.on 'fetch:success', (product_attributes_collection)->
        view = new ProductCreate.Attributes
          model: product
          collection: attributes
          product_attributes: product_attributes

        self.layoutView.content_region.show(view)

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