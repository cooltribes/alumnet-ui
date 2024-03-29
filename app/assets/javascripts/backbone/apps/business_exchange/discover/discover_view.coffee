@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    template: 'business_exchange/_shared/templates/discover_task'

  class Discover.Profile extends AlumNet.BusinessExchangeApp.Shared.Profile
    template: 'business_exchange/_shared/templates/profile'

  class Discover.TasksList extends Marionette.CompositeView
    template: 'business_exchange/discover/templates/tasks_list'
    childView: Discover.Task
    childViewContainer: '.tasks-container'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "post_until", type: "date", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
      ])

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .advanced-search-link': 'advancedSearch'
      'click .js-search': 'search'
      'click .js-advancedSearch': 'toggleAdvancedSearch'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'

    ui:
      'loading': '.throbber-loader'
      
    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMore')      
      $(window).scroll(@loadMore)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMore: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'business:reload'

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    toggleAdvancedSearch: (e)->
      e.preventDefault()
      $('#js-advanced-search-container').toggle()

    advancedSearch: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @collection.fetch
        data: { q: query }

    search: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      @trigger('business:search', { q: { name_cont: value } } )
      #@collection.fetch
      #  data: { q: { name_cont: value } }


    clear: (e)->
      e.preventDefault()
      @collection.fetch()

  class Discover.ProfilesList extends Discover.TasksList
    template: 'business_exchange/discover/templates/profiles_list'
    childView: Discover.Profile
    childViewContainer: '.profiles-container'

    ui:
      'loading': '.throbber-loader'
      
    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMore')      
      $(window).scroll(@loadMore)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')
      
    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "company_name", type: "string", values: "" },
        { attribute: "profile_first_name_or_profile_last_name", type: "string", values: "" },

      ])

    search: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      @trigger('business:search', { q: { m: 'or', profile_first_name_cont_any: value.split(" "), profile_last_name_cont_any: value.split(" ") } } )
      #@collection.fetch
      #  data:
      #    q:
      #      m: 'or'
      #      profile_first_name_cont_any: value.split(" ")
      #      profile_last_name_cont_any: value.split(" ")


  class Discover.Layout extends  Marionette.LayoutView
    template: 'business_exchange/discover/templates/discover_container'
    regions:
      content: '#discover-content'

    ui:
      'linkDiscoverTask': '.discover-tasks'
      'linkDiscoverProfile': '.discover-profiles'

    events:
      'click @ui.linkDiscoverTask': 'discoverTasks'
      'click @ui.linkDiscoverProfile': 'discoverProfiles'

    initialize: (options)->
      @classes = {
        "people": ""
        "tasks": ""
      }

      @classes[options.view] = " sortingMenu__item__link--active "

    templateHelpers: ->
      active: (value)=>
        @classes[value]


    discoverTasks: (e)->
      e.preventDefault()
      @ui.linkDiscoverProfile.removeClass('sortingMenu__item__link--active')
      @ui.linkDiscoverTask.addClass('sortingMenu__item__link--active')
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch()
      tasksList = new Discover.TasksList
        collection: tasks
      @content.show(tasksList)

    discoverProfiles: (e)->
      e.preventDefault()
      @ui.linkDiscoverTask.removeClass('sortingMenu__item__link--active')
      @ui.linkDiscoverProfile.addClass('sortingMenu__item__link--active')
      profiles = new AlumNet.Entities.BusinessCollection
      profiles.url = AlumNet.api_endpoint + "/business"
      profiles.fetch()
      profilesList = new Discover.ProfilesList
        collection: profiles
      @content.show(profilesList)