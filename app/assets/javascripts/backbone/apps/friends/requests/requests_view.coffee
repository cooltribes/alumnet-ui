@AlumNet.module 'FriendsApp.Requests', (Requests, @AlumNet, Backbone, Marionette, $, _) ->
  class Requests.RequestView extends Marionette.ItemView
    template: 'friends/requests/templates/request'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
    events:
      'click #js-accept-friendship':'clickedAccept'
      'click #js-delete-friendship':'clickedDelete'

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'delete'

    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'


  class Requests.RequestsView extends Marionette.CompositeView
    template: 'friends/requests/templates/requests_container'
    childView: Requests.RequestView

    ui:
      'filterLinkContainer': '#filter-link-container'
      'requestsSentLink':'#js-requests-sent'
      'requestsReceivedLink':'#js-requests-received'
    events:
      'click #js-requests-sent, #js-requests-received':'getRequests'

    getRequests: (e)->
      e.stopPropagation()
      e.preventDefault()
      if $(e.currentTarget).attr('id') == 'js-requests-sent'
        filter = 'sent'
      else
        filter = 'received'
      @trigger 'get:requests', filter

    toggleLink: (filter)->
      if filter == 'sent'
        @ui.filterLinkContainer.html("<li role='presentation' class='sortingMenu__item sortingMenu__item--lg'>
        <a href='#' class='sortingMenu__item__link' id='js-requests-received'>Resquests received</a></li>")
      else
        @ui.filterLinkContainer.html("<li role='presentation' class='sortingMenu__item sortingMenu__item--lg'>
        <a href='#' class='sortingMenu__item__link' id='js-requests-sent'>Resquests sent</a></li>")
