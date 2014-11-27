@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.ConversationView extends Marionette.ItemView
    template: 'home/conversations/templates/conversation'
    tagName: 'li'
    triggers:
      'click .js-conversation': 'conversation:clicked'

  class Conversations.MessageView extends Marionette.ItemView
    template: 'home/conversations/templates/message'
    ui:
      'markReadLink': '.js-mark-as-read'
      'markUnReadLink': '.js-mark-as-unread'
    events:
      'click .js-mark-as-unread': 'clickedUnReadLink'
      'click .js-mark-as-read': 'clickedReadLink'

    clickedReadLink: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'click:read'

    clickedUnReadLink: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'click:unread'

    toggleLink: ->
      if @ui.markReadLink.hasClass('js-mark-as-read')
        @ui.markReadLink.removeClass('js-mark-as-read').addClass('js-mark-as-unread').html("Mark as Unread")
      else
        @ui.markReadLink.removeClass('js-mark-as-unread').addClass('js-mark-as-read').html("Mark as Read")


  class Conversations.ConversationsView extends Marionette.CollectionView
    template: 'home/conversations/templates/conversations_container'
    childView: Conversations.ConversationView
    tagName: 'ul'
    className: 'conversations-container'

  class Conversations.NewConversationView extends Marionette.CompositeView
    template: 'home/conversations/templates/new_conversation'
    childView: Conversations.MessageView
    ui:
      'inputBody': '#body'
      'inputSubject': '#subject'
      'selectRecipients': '#recipients'
    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != '' && data.recipients != ''
        data.recipients = data.recipients.split(',')
        @trigger 'conversation:submit', data
        @ui.inputSubject.val('')
        @ui.inputBody.val('')
        @ui.selectRecipients.val('')

    onRender: ->
      @ui.selectRecipients.select2
        tags: []
        placeholder: "Select a Friend"
        multiple: true
        tokenSeparators: [',', ', '],
        dropdownAutoWidth: true,
        minimumInputLength: 3,
        ajax:
          url: AlumNet.api_endpoint + '/me/friendships/friends'
          dataType: 'json'
          data: (term)->
            q:
              m: 'or'
              profile_first_name_cont: term
              profile_last_name_cont: term
          results: (data, page) ->
            results:
              data
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name

  class Conversations.ReplyView extends Marionette.CompositeView
    template: 'home/conversations/templates/reply'
    childView: Conversations.MessageView
    childViewContainer: '.messages-container'
    ui:
      'inputBody': '#body'

    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        @trigger 'reply:submit', data
        @ui.inputBody.val('')


  class Conversations.Layout extends Marionette.LayoutView
    template: 'home/conversations/templates/layout'
    regions:
      conversations: '#conversations-region'
      messages: '#messages-region'
    triggers:
      'click #js-new-conversation': 'new:conversation'

