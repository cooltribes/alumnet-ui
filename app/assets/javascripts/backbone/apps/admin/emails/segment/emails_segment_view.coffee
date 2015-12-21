@AlumNet.module 'AdminApp.EmailsSegment', (EmailsSegment, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsSegment.Layout extends Marionette.LayoutView
    template: 'admin/emails/segment/templates/layout'
    className: 'container'

    regions:
      tableSegment: "#tableSegment"

  class EmailsSegment.User extends Marionette.ItemView
    template: 'admin/emails/segment/templates/_user'

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

  class EmailsSegment.Segment extends Marionette.ItemView
    template: 'admin/emails/segment/templates/_segment'
    tagName: 'tr margin_top_small'

  class EmailsSegment.Table extends Marionette.CompositeView
    template: 'admin/emails/segment/templates/tableContainer'
    childView: EmailsSegment.Segment
    childViewContainer: '#segment-container'

    events:
      'click #js-new-segment': 'addSegment'

    addSegment: (e)->
      e.preventDefault()
      modal = new EmailsSegment.ModalNewSegment

      $('#container-modal-new-segment').html(modal.render().el)
  
  class EmailsSegment.Users extends Marionette.CompositeView
    template: 'admin/emails/segment/templates/users'
    childViewContainer: '#list-users'
    childView: AlumNet.AdminApp.EmailsNew.User

  class EmailsSegment.ModalNewSegment extends Backbone.Modal
    template: 'admin/emails/segment/templates/modal_new_segment'
    cancelEl: '#js-close'
    
    regions:
      'users': '#users'

    onShow: ->
      collection = new Backbone.Collection [
        name: "name1"
        ,
        name: "name2"
      ]
      contentView = new EmailsSegment.Users
        collection: collection
        
      @users.show(contentView)






    
  

