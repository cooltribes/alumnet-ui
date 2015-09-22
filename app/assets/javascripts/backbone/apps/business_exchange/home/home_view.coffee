@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Home.Layout extends Marionette.LayoutView
    template: 'business_exchange/home/templates/home_layout'

    ui:
      'modalBusiness':'#js-modal-business'
    #   start_date: ".js-start-date"
    #   end_date: ".js-end-date"
    #   submit: ".js-submit"

    events:
      'click @ui.modalBusiness': 'showModal'
    #   'click @ui.submit' : 'sendDates'

    showModal: (e)->
      e.preventDefault()
      modal = new Home.ModalBusiness
      $('#container-modal-business').html(modal.render().el)

    regions:
      profiles: '.profiles-region'
      tasks: '.tasks-region'

    # templateHelpers: ->

  class Home.Tasks extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Task

  class Home.Profiles extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Profile

  class Home.ModalBusiness extends Backbone.Modal
    template: 'business_exchange/home/templates/modal'
    cancelEl: '#js-close' 