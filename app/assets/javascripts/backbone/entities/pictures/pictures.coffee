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

    prev: ->
      if !@collection
        return false

      currentIndex = @collection.indexOf(@)
      prevIndex = currentIndex - 1
      console.log prevIndex
      prevIndex = (@collection.length - 1) if prevIndex < 0
      console.log prevIndex

      nextModel = @collection.at(prevIndex)

    next: ->
      if !@collection
        return false

      currentIndex = @collection.indexOf(@)
      nextIndex = currentIndex + 1
      nextIndex = 0 if nextIndex >= @collection.length

      nextModel = @collection.at(nextIndex)
      
    
  class Entities.PictureCollection extends Backbone.Collection
    model: Entities.Picture
