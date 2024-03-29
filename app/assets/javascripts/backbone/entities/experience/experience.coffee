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

      ########      0: 'aiesecExperience'
      1: 'alumniExperience'
      2: 'academicExperience'
      3: 'professionalExperience'
      asTitle: false

    validation:
      name:
        required: true
        msg: 'Name of the position is required'
      description:
        maxLength: 2048
        required: (value, attr, computedState) ->
          @get("exp_type") == 0 || @get("exp_type") == 1
      organization_name:
        required: (value, attr, computedState) ->
          @get("exp_type") == 2 || @get("exp_type") == 3
      start_year: "checkDate"
      end_year: "checkDate"
      committee_id:
        required: (value, attr, computedState) ->
          @get("exp_type") == 0
      # region_id:
      #   required: (value, attr, computedState) ->
      #     if @get("exp_type") == 0 || @get("exp_type") == 1
      #       @get("country_id") == ''

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

      #Si el usuario no selecciona mes, se pone mes por defecto en 1 (enero) y el dia en 01
      #Si el usuario selecciona mes 1 (enero), el dia se pone en 02.
      if parseInt(month) == 1 then day = 2

      if month == '' then month = "01"

      if year == 'current'
        @set "current", true
        year = 0 #"0000"
        month = 0 # "00"
        day = 0 # "00"

      @set "#{attr}_date", "#{year}-#{month}-#{day}"

    decodeDates: ->
      @decodeDate('start')
      @decodeDate('end')

    decodeDate: (attr)->
      date = @get "#{attr}_date"
      unless !date
        date = moment(date, "YYYY-MM-DD")
        day = date.date()

        month = date.month() + 1

        if month == 1 && day == 1
          month = ""

        year = date.year()
      else
        year = "current"
        month = ""


      @set "#{attr}_year", year
      @set "#{attr}_month", month


    getLocation: ()->
      city = country = ""
      if @get("city")
        city = "#{@get("city").name} - "

      if @get("country")
        country = "#{@get("country").name}"

      if (city? || country?) then return "#{city}#{country}"

      "No Location"

    getOrganization: ()->
      if @get("organization_name")
        @get("organization_name")
      else
        false

    getStartDate: ()->
      date = moment(@get("start_date"))
      date.format("MMM YYYY")


    getEndDate: ()->
      if @get("end_date")
        date = moment(@get("end_date"))
        return date.format("MMM YYYY")
      else
        "Current"

    getExperienceId: ->
      @experienceId[@get "exp_type"]

    getExperienceType: ->
      @experienceType[@get "exp_type"]

    getMonthType: ->
      @MonthType[@get "Month_type"]

    canBeDeleted: ->
      #if this experience belongs to a collection and its type is not AIESEC
      return true if (@collection?) && @get("exp_type") != 0

      #if there are more than 1 Aiesec experiences, then this can be deleted
      return @collection.where({"exp_type": 0, "asTitle": false}).length > 1



    experienceType:
      0: 'AIESEC Experience'
      1: 'Alumni Experience'
      2: 'Academic Experience'
      3: 'Professional Experience'

    experienceId:
      0: 'aiesecExperience'
      1: 'alumniExperience'
      2: 'academicExperience'
      3: 'professionalExperience'

    MonthType:
      1: 'January'
      2: 'February'
      3: 'March'
      4: 'April'
      5: 'May'
      6: 'June'
      7: 'July'
      8: 'August'
      9: 'September'
      10: 'October'
      11: 'November'
      12: 'December'

  class Entities.ExperienceCollection extends Backbone.Collection
    model: Entities.Experience

    addTitles: ->
      types = [0..3]

      _.forEach types, (element)  ->
        newExperience = new AlumNet.Entities.Experience
          exp_type: element
          first: true
          asTitle: true

        @push newExperience
      ,
        this

      @sort()


    setOrder: ->
      @comparator = (a, b)->
        typeA = a.get("exp_type")
        typeB = b.get("exp_type")
        end_dateA = a.get "end_date"
        end_dateB = b.get "end_date"
        dateA = moment(end_dateA)
        dateB = moment(end_dateB)

        positions = [2,1,3,0] #Arbitrary order for experience types

        resp = positions[typeA] - positions[typeB]

        if resp == 0

          if a.get("asTitle")
            # return -1
            resp = -1
          else

            if a.get("asTitle") == b.get("asTitle")
              #Order inside a group of experiences depending on type
              if end_dateA == null
                resp = -1
              else
                if end_dateB != null
                  resp = -dateA.diff(dateB)
                else
                  resp = 1

            else
              resp = 1
        resp