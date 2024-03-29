@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Tasks extends Backbone.Model
  # EMPLOYMENT_TYPES = { 0 => "Full-time", 1 => "Part-time", 2 => "Internship", 3 => "Temporary"}
  # POSITION_TYPES = { 0 => "Top Management/Director", 1 => "Middle management", 2 => "Senior Specialist",
  #   3 => "Junior Specialist", 4 => "Entry job" }
    @EMPLOYMENT_TYPES: [
      { value: 0, text: "Full-time"  },
      { value: 1, text: "Part-time"  },
      { value: 2, text: "Internship" },
      { value: 3, text: "Temporary"  },
    ]

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Name is required, must be less than 250 characters long."
      description:
        required: true
        # maxLength: 2048
        msg: "Description is required, must be less than 2048 characters long"
      nice_have_list:
        required: true

    canApply: ->
      @get('user_can_apply')

    canInvite: ->
      @canDelete()

    canEdit: ->
      @canDelete()

    canDelete: ->
      @get('user').id == AlumNet.current_user.id

    daysRemaining: ->
      post_untilFormat = moment(@get('post_until'))
      today = moment()
      days_Remaining = post_untilFormat.diff(today,'days')
      if days_Remaining <= 0
        days_Remaining = 0
      else
        days_Remaining

    totalDays: ->
      createFormat = moment(@get('created_at'))
      post_untilFormat = moment(@get('post_until'))
      daysTotal = post_untilFormat.diff(createFormat,'days')
    
    get_nice_have_attributes_by: (custom_field)->
      if @get('nice_have_attributes')
        _.where(@get('nice_have_attributes'), { custom_field: custom_field })
      else
        []

    get_must_have_attributes_by: (custom_field)->
      if @get('must_have_attributes')
        _.where(@get('must_have_attributes'), { custom_field: custom_field })
      else
        []

    nice_have_initial_values: (custom_field)->
      data = []
      _.each @get_nice_have_attributes_by(custom_field), (element, index, list)->
        data.push { id: element.profinda_id, text: element.value }
      data

    must_have_initial_values: (custom_field)->
      data = []
      _.each @get_must_have_attributes_by(custom_field), (element, index, list)->
        data.push { id: element.profinda_id, text: element.value }
      data

    getCreator: ->
      if @get('user')
        new AlumNet.Entities.User @get('user')
      else
        null

  ##JOB EXCHANGE

  class Entities.JobExchange extends Entities.Tasks
    urlRoot: ->
      AlumNet.api_endpoint + '/job_exchanges'

  class Entities.JobExchangeCollection extends Backbone.Collection
    model:
      Entities.JobExchange
    rows: 6
    page: 1
    url: ->
      AlumNet.api_endpoint + '/job_exchanges'

  ##BUSINESS EXCHANGE

  class Entities.BusinessExchange extends Entities.Tasks
    urlRoot: ->
      AlumNet.api_endpoint + '/business_exchanges'

    nice_have_initial_values: ->
      data = []
      if @get('nice_have_attributes')
        _.each @get('nice_have_attributes'), (element, index, list)->
          data.push { id: element.profinda_id, value: element.value }
        data
      else
        data

    must_have_initial_values: ->
      data = []
      if @get('must_have_attributes')
        _.each @get('must_have_attributes'), (element, index, list)->
          data.push { id: element.profinda_id, value: element.value }
        data
      else
        data

  class Entities.BusinessExchangeCollection extends Backbone.Collection
    model:
      Entities.BusinessExchange
    page: 1
    rows: 6
    url: ->
      AlumNet.api_endpoint + '/business_exchanges'

  ##MEETUP EXCHANGE

  class Entities.MeetupExchange extends Entities.Tasks
    urlRoot: ->
      AlumNet.api_endpoint + '/meetup_exchanges'

    country_initial_value: ->
      data = {}
      if @get('must_have_attributes')
        country = _.findWhere(@get('must_have_attributes'), {custom_field: "alumnet_country_residence"})
        data = { id: country.profinda_id, text: country.value } if country
      data

    city_initial_value: ->
      data = {}
      if @get('nice_have_attributes')
        city = _.findWhere(@get('nice_have_attributes'), {custom_field: "alumnet_city_residence"})
        data = { id: city.profinda_id, text: city.value } if city
      data

    attributes_initial_values: ->
      data = []
      if @get('nice_have_attributes')
        attributes = _.reject @get('nice_have_attributes'), (element)->
          element.custom_field == "alumnet_city_residence"
        _.each attributes, (element, index, list)->
          data.push { id: element.profinda_id, value: element.value }
      data

    get_location: ->
      location = []
      location.push @city_initial_value().text unless @city_initial_value().text == undefined
      location.push @country_initial_value().text unless @country_initial_value().text == undefined
      location.join(", ")

    validation:
      arrival_date:
        required: true
        msg: "Arrival Date is required"
      post_until:
        required: true
        msg: "Departure Date is required"

  class Entities.MeetupExchangeCollection extends Backbone.Collection
    model:
      Entities.MeetupExchange
    url: ->
      AlumNet.api_endpoint + '/meetup_exchanges'