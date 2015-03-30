@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Picture extends Backbone.Model
  
    getLocation: ->
      city = country = ""
      if @get("city")
        city = "#{@get("city").text} - "

      if @get("country")
        country = "#{@get("country").text}"

      if (city? || country?) then return "#{city}#{country}"

      null  

    # validation:
    #   name:
    #     required: true

  class Entities.PictureCollection extends Backbone.Collection
    model: Entities.Picture

  