@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    className: 'container'
    template: 'business_exchange/_shared/templates/discover_task'

  class Discover.Profile extends AlumNet.BusinessExchangeApp.Shared.Profile
    className: 'container'
    template: 'business_exchange/_shared/templates/profile'

  class Discover.TasksList extends Marionette.CompositeView
    template: 'business_exchange/discover/templates/tasks_list'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "post_until", type: "date", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
      ])

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .advanced-search-link': 'advancedSearch'
      'click .search': 'search'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    advancedSearch: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @collection.fetch
        data: { q: query }

    search: (e)->
      e.preventDefault()
      value = $('#input-search').val()
      @collection.fetch
        data: { q: { name_cont: value } }

    clear: (e)->
      e.preventDefault()
      @collection.fetch()

  class Discover.ProfilesList extends Discover.TasksList
    template: 'business_exchange/discover/templates/profiles_list'
    childView: Discover.Profile
    childViewContainer: '.profiles-container'
    className: 'container'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "company_name", type: "string", values: "" },
        { attribute: "profile_first_name_or_profile_last_name", type: "string", values: "" },

      ])

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

    discoverTasks: (e)->
      e.preventDefault()
      @ui.linkDiscoverProfile.removeClass('active')
      @ui.linkDiscoverTask.addClass('active')
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch()
      tasksList = new Discover.TasksList
        collection: tasks
      @content.show(tasksList)

    discoverProfiles: (e)->
      e.preventDefault()
      @ui.linkDiscoverTask.removeClass('active')
      @ui.linkDiscoverProfile.addClass('active')
      profiles = new AlumNet.Entities.BusinessCollection
      profiles.url = AlumNet.api_endpoint + "/business"
      profiles.fetch()
      profilesList = new Discover.ProfilesList
        collection: profiles
      @content.show(profilesList)