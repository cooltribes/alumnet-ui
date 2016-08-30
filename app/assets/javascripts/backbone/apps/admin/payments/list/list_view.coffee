@AlumNet.module 'AdminApp.ListPayments', (ListPayments, @AlumNet, Backbone, Marionette, $, _) ->
	class ListPayments.Payment extends Marionette.ItemView
    template: 'admin/payments/list/templates/_list'
    tagName: "tr"

    templateHelpers: ->
      location: ->
        if !@country.name
          @user.location
        else
          @country.name

  class ListPayments.Layout extends Marionette.CompositeView
    template: 'admin/payments/list/templates/list_container'
    childView: ListPayments.Payment 
    childViewContainer: '#list-container'
    currentQuery: {}

    ui:
      #'prevButton': '#prevButton'
      #'nextButton': '#nextButton'
      'prevFilterButton': '#prevFilterButton'
      'nextFilterButton': '#nextFilterButton'
      'totalRecords': '.js-total-records'

    events:
      'click .js-download': 'exportCSV'

    initialize: (options) ->
      view = @
      AlumNet.setTitle('Payments Management')
      @listenTo this, 'change:total', @updateTotal
      @total_collection = new AlumNet.Entities.PaymentsCollection
      @total_collection.url = AlumNet.api_endpoint + '/payments'
      @total_collection.fetch
        success: ->
          view.pagination()
          view.updateTotal()

    updateTotal: ->
      @ui.totalRecords.html(@total_collection.length)

    templateHelpers: ->
      view = @
      totalRecords: @collection.length
      pagination_buttons: ->
        class_li = ''
        class_link = ''
        html = ""
        if (view.collection.state.totalPages > 1)
          html = '<nav id="pag"><ul class="pagination"><li><a href="#admin/payments" id="prevButton" style="display:none">Prev</a></li>'
          for page in [1..view.collection.state.totalPages]
            if (page == 1)
              class_li = "active"
              class_link = "paginationUsers "
            else
              class_li = ""
              class_link = ""

            html += '<li class= "'+class_li+'" id='+page+'><a class= "page_button" href="#admin/payments" id="link_'+page+'">'+page+'</a></li>  '

          html += '<li class="next"><a href="#admin/payments" id="nextButton">Next</a></li></ul></nav>'
        html

    onRender: ->
      view = @
      $('.js-from-date').Zebra_DatePicker
        format: 'd-m-Y'
        show_icon: false
        default_position: 'below'
        show_clear_date: false
        show_select_today: false
        onSelect: (date)->
          view.advancedSearch()

      $('.js-to-date').Zebra_DatePicker
        format: 'd-m-Y'
        show_icon: false
        default_position: 'below'
        show_clear_date: false
        show_select_today: false
        onSelect: (date)->
          view.advancedSearch()

    advancedSearch: ->
      query = {created_at_gteq: $('.js-from-date').val(), created_at_lteq: $('.js-to-date').val()}
      @currentQuery = query
      view = @
      view.collection.fetch
        data: { q: query }
        success: ->
          view.trigger 'change:total'
          view.pagination()
      view.total_collection.fetch
        data: { q: query }
        success: ->
          view.pagination()
          view.updateTotal()

    exportCSV: (e)->
      e.preventDefault()
      Backbone.ajax
        method: 'POST'
        url: AlumNet.api_endpoint + "/payments/csv"
        data: { q: @currentQuery }
        success: (csvData)->
          blob = new Blob([csvData], { type: 'text/csv' })
          saveAs(blob, "alumnet_users_#{moment().format('DDMMYYYYHHmm')}.csv")

    pagination: ->
      that = @
      $('#pagination').twbsPagination
        totalPages: that.total_collection.length / that.collection.per_page
        onPageClick: (event, page) ->
          that.collection.page = page
          that.collection.url = AlumNet.api_endpoint + '/payments?page='+page+'&per_page='+that.collection.per_page
          that.collection.fetch
            data: { q: that.currentQuery }