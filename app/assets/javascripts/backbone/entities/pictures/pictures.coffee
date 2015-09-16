@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Picture extends Backbone.Model

    initialize: ->
      @comments = new Entities.CommentsCollection
      @comments.url = AlumNet.api_endpoint + '/pictures/' + @get('id') + '/comments'


    getLocation: ->
      city = country = ""
      if @get("city")
        city = "#{@get("city").name} - "

      if @get("country")
        country = "#{@get("country").name}"

      if (city? || country?) then return "#{city}#{country}"

      null

    prev: ->
      if !@collection
        return false

      currentIndex = @collection.indexOf(@)
      prevIndex = currentIndex - 1
      prevIndex = (@collection.length - 1) if prevIndex < 0

      nextModel = @collection.at(prevIndex)

    next: ->
      if !@collection
        return false

      currentIndex = @collection.indexOf(@)
      nextIndex = currentIndex + 1
      nextIndex = 0 if nextIndex >= @collection.length

      nextModel = @collection.at(nextIndex)

    sumLike: ->
      count = @get('likes_count')
      @set('likes_count', count + 1)
      @set('you_like', true)

    remLike: ->
      count = @get('likes_count')
      @set('likes_count', count - 1)
      @set('you_like', false)


  class Entities.PictureCollection extends Backbone.Collection
    model: Entities.Picture
