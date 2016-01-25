@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.SearchFilter extends Backbone.Model
    defaults:
      active: false
      text: ""
      type: null
      id: null

       
  
  class Entities.SearchFiltersCollection extends Backbone.Collection
    model: Entities.SearchFilter    
    type: "all"
    
