@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Link extends Backbone.Model
    validation:
      title:
        required: true
      description:
        required: true
      url:
        required: true
        pattern: 'url'

  class Entities.LinksCollection extends Backbone.Collection
    model: Entities.Link