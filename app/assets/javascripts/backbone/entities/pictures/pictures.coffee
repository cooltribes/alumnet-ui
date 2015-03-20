@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Picture extends Backbone.Model
    
    # validation:
    #   name:
    #     required: true

  class Entities.PictureCollection extends Backbone.Collection
    model: Entities.Picture

  