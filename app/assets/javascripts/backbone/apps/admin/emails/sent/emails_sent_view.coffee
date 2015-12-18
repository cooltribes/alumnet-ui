@AlumNet.module 'AdminApp.EmailsSent', (EmailsSent, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsSent.Layout extends Marionette.LayoutView
    template: 'admin/emails/sent/templates/layout'
    className: 'container'

    regions:
      search: "#search"
      table: "#table"

  class EmailsSent.Search extends Marionette.CompositeView
    template: 'admin/emails/sent/templates/search'
    childViewContainer: '#list-users'

  class EmailsSent.Table extends Marionette.CompositeView
    template: 'admin/emails/sent/templates/sent_table'

    
  

