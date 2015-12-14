@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsNew.Layout extends Marionette.LayoutView
    template: 'admin/emails/new/templates/layout'
    className: 'container'

    regions:
      groups_users: "#groups_users"
      create_email: "#create_email"
      users: "#users"

  class EmailsNew.User extends Marionette.ItemView
    template: 'admin/emails/new/templates/_user'

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

  class EmailsNew.AddFilter extends Marionette.LayoutView
    template: 'admin/emails/new/templates/_add_filter'

  class EmailsNew.GroupsUsers extends Marionette.CompositeView
    template: 'admin/emails/new/templates/groups_users'
    childViewContainer: '#add-filter'
    childView: EmailsNew.AddFilter

    events:
      'click #js-remove-associated-span': 'removeAsocciatedMailChimp'
      'click #js-add-filter': 'addFilter'

    removeAsocciatedMailChimp: (e)->

    addFilter: (e)->
      console.log "PRESIONO AGREGAR FILTRO"

  class EmailsNew.Users extends Marionette.CompositeView
    template: 'admin/emails/new/templates/users'
    childViewContainer: '#list-users'
    childView: EmailsNew.User

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
      

    
  

