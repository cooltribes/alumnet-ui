@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Filter extends Backbone.Model
    defaults:
      first: false
      field: ""
      comparator: ""
      value: ""
      operator: 1
   
    

  class Entities.Search extends Backbone.Collection
    model: Entities.Filter
