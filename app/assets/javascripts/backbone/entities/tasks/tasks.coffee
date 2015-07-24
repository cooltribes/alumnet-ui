@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Tasks extends Backbone.Model
  # EMPLOYMENT_TYPES = { 0 => "Full-time", 1 => "Part-time", 2 => "Internship", 3 => "Temporary"}
  # POSITION_TYPES = { 0 => "Top Management/Director", 1 => "Middle management", 2 => "Senior Specialist",
  #   3 => "Junior Specialist", 4 => "Entry job" }

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
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

  class Entities.MeetupExchangeCollection extends Backbone.Collection
    model:
      Entities.MeetupExchange
    url: ->
      AlumNet.api_endpoint + '/meetup_exchanges'