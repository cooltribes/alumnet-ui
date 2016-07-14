@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.LayerConversation extends Backbone.Model
    defaults:
      type: 'conversations'
      title: 'unknow'

  class Entities.LayerConversationCollection extends Backbone.Collection
    model: AlumNet.Entities.Conversation

  class Entities.LayerMessage extends Backbone.Model
    defaults:
      type: 'messages'
      sender:
        id: null
        fullname: 'unknow'
        avatar_url: ''

    isCurrentUser: ->
      if @get('sender').id == AlumNet.current_user.id then true else false

  class Entities.LayerMessageCollection extends Backbone.Collection
    model: AlumNet.Entities.Message