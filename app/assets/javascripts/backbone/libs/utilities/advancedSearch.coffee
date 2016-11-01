@AlumNet.module 'AdvancedSearch', (AdvancedSearch, @AlumNet, Backbone, Marionette, $, _) ->
  class AdvancedSearch.Searcher
    STRING_COMPARATORS: [{value: "eq", text: "="}, {value: "cont", text: "Contains", selected: true}]

    NUMERIC_COMPARATORS: [{value: "gt", text: ">"}, {value: "lt", text: "<"},
      {value: "lteq", text: "<="}, {value: "gteq", text: ">="}, {value: "eq", text: "=", selected: true}]

    OPTION_COMPARATORS:[{value: "eq", text: "=", selected: true}]

    DATE_COMPARATORS: [{value: "gt", text: ">"}, {value: "lt", text: "<"},
      {value: "lteq", text: "<=", selected: true}, {value: "gteq", text: ">="}, {value: "eq", text: "="}]

    constructor: (container_id, options)->
      @activateOr = false
      @container = $("##{container_id}")
      @htmlFilter = '<div class="filter row margin_top_medium">' + @container.find('.filter').html() + "</div>"
      @options = options
      @initializeEvents()

    addNewFilter: ->
      @container.append @htmlFilter

    clearFilters: ->
      filters = @container.find('.filter')
      first_filter = filters[0]
      @_resetFilter($(first_filter))
      return if filters.length == 1
      filters.each (index)->
        $(@).remove() unless index == 0

    _resetFilter: ($filter)->
      $filter.find('.filter-attribute-container select').val("")
      $filter.find('.filter-value-container').html @_inputForFilter("")

    _getOptionsFor: (attribute)->
      _.where(@options, {attribute: attribute})[0]

    _htmlForComparator: (type)->
      switch type
        when "string" then @_generateHtmlOptionsForSelect @STRING_COMPARATORS
        when "numeric" then @_generateHtmlOptionsForSelect @NUMERIC_COMPARATORS
        when "option" then @_generateHtmlOptionsForSelect @OPTION_COMPARATORS
        when "date" then @_generateHtmlOptionsForSelect @DATE_COMPARATORS
        else ""

    _generateHtmlOptionsForSelect: (options, placeholder)->
      if placeholder == undefined then placeholder = "Search field"
      htmlOptions = "<option value=''>#{placeholder}</option>"
      _.each options, (option, index, list)->
        selected = if option.selected then "selected" else ""
        htmlOptions += "<option value='#{option.value}' #{selected}>#{option.text}</option>"
      htmlOptions

    _inputForFilter: (options)->
      if Array.isArray(options.values) && options.type == "option"
        "<select class='filter-value filters__input filters__input--lg form-control input-lg'>" + @_generateHtmlOptionsForSelect(options.values, 'Select Value') + "</select>"
      else if options.type == "date"
        "<input class='filter-value filters__input filters__input--lg form-control input-lg date-search' value='#{options.values || ""}'>"
      else
        "<input class='filter-value filters__input filters__input--lg form-control input-lg' value='#{options.values || ""}'>"

    _initializeDateInput: (valueContainer)->
      dateInput = valueContainer.find('.date-search').first()
      dateInput.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        default_position: 'below'

    generateOptions: ($filterContainer, value)->
      filterComparator = $filterContainer.find('.filter-comparator')
      valueContainer = $filterContainer.find('.filter-value-container')
      options = @_getOptionsFor(value)
      if options
        filterComparator.html @_htmlForComparator(options.type)
        valueContainer.html @_inputForFilter(options)
      else
        filterComparator.html ""
        valueContainer.html @_inputForFilter("")
      if options.type == "date"
        @_initializeDateInput(valueContainer)

    getQuery: ->      
      @container.find('.filter').each (index)->
        filter = $(@)
        attribute = filter.find('.filter-attribute').val()
        comparator = filter.find('.filter-comparator').val()
        value = filter.find('.filter-value').val()
        unless attribute == "" || comparator == "" || value == ""
          query["#{attribute}_#{comparator}"] = value
      query['m'] = 'or' if @activateOr      
      query

    initializeEvents: ->
      self = @
      @container.on "click", ".close-filter", (event)->
        event.preventDefault()
        $(@).parent('.filter').remove() if self.container.find('.filter').length > 1

      @container.on "change", ".filter-attribute", (event)->
        value = $(@).val()
        filterContainer = $(@).closest('.filter')
        self.generateOptions(filterContainer, value)

    checkAttributeAndComparator: (attr, compar)->
      cont= 0
      @container.find('.filter').each (index)->
        filter = $(@)
        attribute = filter.find('.filter-attribute').val()
        comparator = filter.find('.filter-comparator').val()           
        if(attribute== attr and comparator==compar )
          cont=cont+1
      cont>1 ? true : false
     