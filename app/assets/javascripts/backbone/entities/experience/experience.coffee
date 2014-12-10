@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Experience extends Backbone.Model
    defaults:
      first: false
      name: ""
      organization_name: ""
      start_year: ""
      start_month: ""
      end_year: ""
      end_month: ""
      description: ""
      country_id: ""
      city_id: ""
      internship: 0

    validation:
      name:
        required: true
      # start_year:
      #   required: true
      # end_year:
      #   required: true
      description:
        required: true
      country_id:
        required: true
      city_id:
        required: true
      committee_id:
        required: (value, attr, computedState) ->
          @get("exp_type") == 0 || @get("exp_type") == 1
      organization_name:
        required: (value, attr, computedState) ->
          @get("exp_type") == 2 || @get("exp_type") == 3
      start_year: "checkDate"
      end_year: "checkDate"

    checkDate: (value, attr, computedState)->
      if value == ''
        Backbone.Validation.validators.required(value, attr, true, @)
      else
        @formatDates()
        start = @get 'start_date'
        end = @get 'end_date'
        if moment(end).diff(moment(start), 'days') < 0
          'End date must be greater than Start date'

    formatDates: ->
      @formatDate('start')
      @formatDate('end')

    formatDate: (attr)->
      day = "01"
      month = @get("#{attr}_month")
      year = @get("#{attr}_year")

      if month == '' then month = "01"

      @set "#{attr}_date", "#{year}-#{month}-#{day}"


  class Entities.ExperienceCollection extends Backbone.Collection
    model: Entities.Experience
