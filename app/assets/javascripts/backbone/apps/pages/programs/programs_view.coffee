@AlumNet.module 'PagesApp.Programs', (Programs, @AlumNet, Backbone, Marionette, $, _) ->

  class Programs.Business extends Marionette.ItemView
    template: 'pages/programs/templates/business_exchange'

  class Programs.Home extends Marionette.ItemView
    template: 'pages/programs/templates/home_exchange'

    ui:
      'modalHome':'#js-modal-home'
    #   start_date: ".js-start-date"
    #   end_date: ".js-end-date"
    #   submit: ".js-submit"

    events:
      'click @ui.modalHome': 'showModal'
    #   'click @ui.submit' : 'sendDates'

    showModal: (e)->
      e.preventDefault()
      modal = new Programs.ModalHome
      $('#container-modal-home').html(modal.render().el)

  class Programs.Job extends Marionette.ItemView
    template: 'pages/programs/templates/job_exchange'

  class Programs.AGroups extends Marionette.ItemView
    template: 'pages/programs/templates/agroups'

  class Programs.AlumNite extends Marionette.ItemView
    template: 'pages/programs/templates/alumnite'

  class Programs.MeetUps extends Marionette.ItemView
    template: 'pages/programs/templates/meetups'

  class Programs.ModalHome extends Backbone.Modal
    template: 'pages/programs/templates/modal'
    cancelEl: '#js-close'