@AlumNet.module 'AdminApp.EmailsSent', (EmailsSent, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsSent.Layout extends Marionette.LayoutView
    template: 'admin/emails/sent/templates/layout'
    className: 'container'

    regions:
      tableSentEmails: "#tableSentEmails"

  class EmailsSent.Emails extends Marionette.ItemView
    template: 'admin/emails/sent/templates/_email'
    tagName: 'tr margin_top_small'

  class EmailsSent.Table extends Marionette.CompositeView
    template: 'admin/emails/sent/templates/tableContainer'
    childView: EmailsSent.Emails
    childViewContainer: '#emails-container'

    
  

