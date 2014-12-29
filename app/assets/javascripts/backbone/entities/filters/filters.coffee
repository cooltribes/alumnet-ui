@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Filter extends Backbone.Model
    defaults:
      first: false
      field: ""
      comparator: ""
      value: ""
      operator: ""
    
    validation:
      field:[
        {
          required: true
          # msg: "Field is required"          
        }
      ]
      comparator:[
        {
          required: true
          # msg: "Field is required"          
        }
      ]
      value:[
        {
          required: true
          # msg: "Field is required"          
        }
      ]
      operator:[
        {
          required: true
          # msg: "Field is required"          
        }
      ]

  class Entities.Search extends Backbone.Collection
    model: Entities.Filter
