class AlumNet.FormatLayerData
  createConversation: (data)->
    if data.lastMessage?
      lastMessage = data.lastMessage.parts[0].body
    else
      lastMessage = null
    new AlumNet.Entities.LayerConversation
      id: data.id
      participants: data.participants
      unreadCount: data.unreadCount
      layerObject: data
      lastMessageBody: lastMessage


  createMessage: (data)->
    new AlumNet.Entities.LayerMessage
      id: data.id
      sender:
        id: data.sender.userId
        fullname: 'unknow'
        avatar_url: ''
      body: data.parts[0].body
      sentAt: data.sentAt
      layerObject: data

  constructor: (type, data)->
    switch type
      when 'message'
        return @createMessage(data)
      when 'conversation'
        return @createConversation(data)

