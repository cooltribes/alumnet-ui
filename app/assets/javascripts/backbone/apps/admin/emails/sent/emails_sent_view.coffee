@AlumNet.module 'AdminApp.EmailsSent', (EmailsSent, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsSent.Layout extends Marionette.LayoutView
    template: 'admin/emails/sent/templates/layout'
    className: 'container'

    regions:
      tableSentEmails: "#tableSentEmails"

  class EmailsSent.Emails extends Marionette.ItemView
    template: 'admin/emails/sent/templates/_email'
    tagName: 'tr margin_top_small'

    initialize: (options)->
      console.log 'initialize'
      console.log options

    templateHelpers: ->
      model = @model
      seen = model.get('details').data[0].summary.opens
      sent = model.get('details').data[0].emails_sent
      clicks = model.get('details').data[0].summary.clicks
      get_sent: sent
      get_seen: seen
      get_clicks: clicks
      get_open_rate: ->
        if sent > 0 then (seen * 100) / sent else 0
      get_ctr: ->
        if sent > 0 then (clicks * 100) / sent else 0

  class EmailsSent.Table extends Marionette.CompositeView
    template: 'admin/emails/sent/templates/tableContainer'
    childView: EmailsSent.Emails
    childViewContainer: '#emails-container'

    initialize: (options)->
      console.log 'initialize table'
      console.log options
    
  

