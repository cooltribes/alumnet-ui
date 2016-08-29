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

    events:
      'click .js-download': 'exportCSV'

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
      view = @
      view.collection.fetch
        data: { q: query }

    exportCSV: (e)->
      e.preventDefault()
      Backbone.ajax
        method: 'POST'
        url: AlumNet.api_endpoint + "/payments/csv"
        data: { q: @currentQuery }
        success: (csvData)->
          blob = new Blob([csvData], { type: 'text/csv' })
          saveAs(blob, "alumnet_users_#{moment().format('DDMMYYYYHHmm')}.csv")