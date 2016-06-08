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
    attrs =
      sender:
        id: data.sender.userId
        fullname: 'unknow'
        avatar_url: ''
      body: data.parts[0].body
      sentAt: data.sentAt
      layerObject: data

    new AlumNet.Entities.LayerMessage attrs