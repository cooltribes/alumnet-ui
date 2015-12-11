@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsNew.Layout extends Marionette.LayoutView
    template: 'admin/emails/new/templates/layout'
    className: 'container'

    regions:
      groups_users: "#groups_users"
      create_email: "#create_email"

  class EmailsNew.User extends Marionette.ItemView
    template: 'admin/emails/new/templates/user'

    ui:
      'select_user': '#js-select-user'
      'deselect_user': '#js-deselect-user'
    events:
      'click @ui.select_user': 'selectUser'
      'click @ui.deselect_user': 'deselectUser'
  

    selectUser: -> 
      $("#js-select-user").removeClass("emails__user").addClass("emails__user--active")
      $("#js-select-user").attr("id","js-deselect-user")

    deselectUser: ->
    
      $("#js-deselect-user").removeClass("emails__user--active").addClass("emails__user")
      $("#js-deselect-user").attr("id","js-select-user")

  class EmailsNew.GroupsUsers extends Marionette.CompositeView
    template: 'admin/emails/new/templates/groups_users'
    childViewContainer: '#list-users'
    childView: EmailsNew.User

    events:
      'click #js-remove-associated-span': 'removeAsocciatedMailChimp'

    removeAsocciatedMailChimp: (e)->
  
  class EmailsNew.CreateEmail extends Marionette.CompositeView
    template: 'admin/emails/new/templates/create_email'

    onShow: ->
      
      summernote_options_description =
        height: 200
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]

      $('#task-description').summernote(summernote_options_description)
      

    
  

