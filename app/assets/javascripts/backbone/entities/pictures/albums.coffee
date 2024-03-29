@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Album extends Backbone.Model

    validation:
      name:
        required: true

    getLocation: ->
      city = country = ""
      if @get("city")
        city = "#{@get("city").text} - "

      if @get("country")
        country = "#{@get("country").text}"

      if (city? || country?) then return "#{city}#{country}"

      null

  class Entities.AlbumCollection extends Backbone.Collection
    model: Entities.Album

