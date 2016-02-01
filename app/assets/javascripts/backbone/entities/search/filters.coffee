@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.SearchFilter extends Backbone.Model
    defaults:
      active: false
      name: ""
      type: null
      id: null
      value: ""
       
  
  class Entities.SearchFiltersCollection extends Backbone.Collection
    model: Entities.SearchFilter    
    type: "all"
    
