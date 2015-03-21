@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Album extends Backbone.Model
    
    validation:
      name:
        required: true

  class Entities.AlbumCollection extends Backbone.Collection
    model: Entities.Album

  