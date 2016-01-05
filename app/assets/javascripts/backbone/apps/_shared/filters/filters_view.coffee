@AlumNet.module 'Shared.Views.Filters', (Filters, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Filters.Row extends Marionette.ItemView
    template: '_shared/filters/templates/_row'

    bindings:
      "#text": "text"

    onRender: ->
      @stickit()        


  class Filters.Layout extends Marionette.CompositeView
    template: '_shared/filters/templates/layout'
    childView: Filters.Row
    childViewContainer: '#rows-region'

    initialize: (options)->      

      locations = [
        text: "Andorra la Vella"
        id: 1
        type: "city"
      , 
        text: "Balkh"
        id: 22
        type: "city"
      ]
      @collection = new AlumNet.Entities.SearchFiltersCollection locations
