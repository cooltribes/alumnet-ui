@AlumNet.module 'EventsApp.Manage', (Manage, @AlumNet, Backbone, Marionette, $, _) ->
  class Manage.Empty extends Marionette.ItemView
    template: 'events/manage/templates/empty'

  class Manage.EventView extends Marionette.ItemView
    template: 'events/manage/templates/event'
    className: 'container'

    initialize: (options)->
      @collection =  options.collection

    templateHelpers: ->
      model = @model
      location: @model.getLocation()
      isPast: @model.isPast()
      select: (value, option)->
        if value == option then "selected" else ""
      attendance_status: ->
        attendance_info = model.get('attendance_info')
        if attendance_info
          attendance_info.status
        else
          null
    ui:
      attendanceStatus: '#attendance-status'
      linkCancel: '#js-attendance-cancel'

    events:
      'change @ui.attendanceStatus': 'changeAttendanceStatus'
      'click @ui.linkCancel': 'cancelEvent'

    cancelEvent: (e)->
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        collection = @collection
        model = @model
        Backbone.ajax
          #url: @model.url()
          url: AlumNet.api_endpoint + '/events/' + model.id
          method: 'DELETE'
          success: (data, textStatus, xhr)->
            collection.remove(model)
          error: (xhr, textStatus, error)->
            if xhr.status == 409
              alert xhr.responseJSON.message


    changeAttendanceStatus: (e)->
      e.preventDefault()
      status = $(e.currentTarget).val()
      attendance = @model.attendance
      if status
        if attendance.isNew()
          attrs = { user_id: AlumNet.current_user.id, event_id: @model.id, status: status }
          attendance.save(attrs)
        else
          attendance.set('status', status)
          attendance.save()
      if status=='going'
        $(e.target).css('background-color','#72da9e')
      if status=='invited'
        $(e.target).css('background-color','#6dc2e9')
      if status=='not_going'
        $(e.target).css('background-color','#ea7952')
      if status=='maybe'
        $(e.target).css('background-color','#f5ac45')


  class Manage.EventsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'events/manage/templates/events_container'
    childView: Manage.EventView
    childViewContainer: ".main-events-area"
    emptyView: Manage.Empty

    childViewOptions: ->
      collection: @collection

    initialize: (options)->
      @parentView = options.parentView
      @query = options.query

      @collection.fetch
        reset: true
        remove: true
        data: @query

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreEvents')
      $(window).scroll(@loadMoreEvents)
      $("#iconsTypeEvents").addClass("hide")

    remove: ->
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      #@ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreEvents: (e)->
      if @collection.nextPage == null
        @endPagination()
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @reloadItems()

    reloadItems: ->
      @query.page = @collection.nextPage
      @collection.fetch
        remove: false
        reset: false
        data: @query

