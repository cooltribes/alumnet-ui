@AlumNet.module 'MeetupExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-4'
    template: 'meetup_exchange/_shared/templates/discover_task'

  class Discover.List extends Marionette.CompositeView
    template: 'meetup_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "arrival_date", type: "numeric", values: "" },
        { attribute: "post_until", type: "numeric", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
      ])
    
    ui:
      'modalMeetups':'#js-modal-meetups'

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .js-search': 'search'
      #'click .search': 'search'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'
      'click @ui.modalMeetups': 'showModal'

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    search: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      value = $('#search_term').val()            
      @collection.fetch
        #data: { q: query }
        data: { q: { name_cont: value } }
        
    clear: (e)->
      e.preventDefault()
      @collection.fetch()

    showModal: (e)->
      e.preventDefault()
      modal = new Discover.ModalMeetups
      $('#container-modal-meetup').html(modal.render().el)

  class Discover.ModalMeetups extends Backbone.Modal
    template: 'meetup_exchange/discover/templates/modal'
    cancelEl: '#js-close'