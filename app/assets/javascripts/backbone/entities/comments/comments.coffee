@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Comment extends Backbone.Model
    validation:
      comment:
        required: true

    sumLike: ->
      count = @get('likes_count')
      @set('likes_count', count + 1)
      @set('you_like', true)

    remLike: ->
      count = @get('likes_count')
      @set('likes_count', count - 1)
      @set('you_like', false)

    commentWithLinks: ()->
      markup_comment = @get 'markup_comment'
      if markup_comment
        mentionRE = /@\[([^\]]+)\]\(([^ \)]+)\)/g
        markup_comment.replace mentionRE, (mention)->
          match = mentionRE.exec(mention)
          if match
            link = "<a href='#users/#{match[2]}/posts'>#{match[1]}</a>"
          else
            link = mention
          mentionRE.lastIndex = 0 #reset the regex because is global /g
          link
      else
        @get 'comment'

    getUserLocation:->
      if @get("user").residence_city.text != ""
        return "#{@get("user").residence_city.text} - #{@get("user").residence_country.text}"
      else
        return "#{@get("user").residence_country.text}"
    


  class Entities.CommentsCollection extends Backbone.Collection
    model: Entities.Comment

  API =
    getNewCommentForPost: (post_id)->
      comment = new Entities.Comment
      comment.urlRoot = AlumNet.api_endpoint + '/posts/' + post_id + '/comments'
      comment

    getNewCommentForPicture: (picture_id)->
      comment = new Entities.Comment
      comment.urlRoot = AlumNet.api_endpoint + '/pictures/' + picture_id + '/comments'
      comment

  AlumNet.reqres.setHandler 'comment:post:new', (post_id)->
    API.getNewCommentForPost(post_id)

  AlumNet.reqres.setHandler 'comment:picture:new', (picture_id)->
    API.getNewCommentForPicture(picture_id)