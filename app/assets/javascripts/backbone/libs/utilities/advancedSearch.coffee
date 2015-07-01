@AlumNet.module 'AdvancedSearch', (AdvancedSearch, @AlumNet, Backbone, Marionette, $, _) ->
  class AdvancedSearch.Searcher
    STRING_COMPARATORS: [{value: "eq", text: "="}, {value: "cont", text: "Contains"}]

    NUMERIC_COMPARATORS: [{value: "gt", text: ">"}, {value: "lt", text: "<"},
      {value: "lteq", text: "<="}, {value: "gteq", text: ">="}, {value: "eq", text: "="}]

    OPTION_COMPARATORS:[{value: "eq", text: "="}]

    constructor: (container_id, options)->
      @activateOr = false
      @container = $("##{container_id}")
      @htmlFilter = '<div class="filter">' + @container.find('.filter').html() + "</div>"
      @options = options
      @initializeEvents()

    addNewFilter: ->
      @container.append @htmlFilter

    _getOptionsFor: (attribute)->
      _.where(@options, {attribute: attribute})[0]

    _htmlForComparator: (type)->
      switch type
        when "string" then @_generateHtmlOptionsForSelect @STRING_COMPARATORS
        when "numeric" then @_generateHtmlOptionsForSelect @NUMERIC_COMPARATORS
        when "option" then @_generateHtmlOptionsForSelect @OPTION_COMPARATORS
        else ""

    _generateHtmlOptionsForSelect: (options, placeholder)->
      if placeholder == undefined then placeholder = "Select Comparator"
      htmlOptions = "<option value=''>#{placeholder}</option>"
      _.each options, (option, index, list)->
        htmlOptions += "<option value='#{option.value}'>#{option.text}</option>"
      htmlOptions

    _inputForFilter: (options)->
      if Array.isArray(options)
        "<select class='filter-value'>" + @_generateHtmlOptionsForSelect(options, 'Select Value') + "</select>"
      else
        "<input class='filter-value' value='#{options}'>"

    generateOptions: ($filterContainer, value)->
      options = @_getOptionsFor(value)
      filterComparator = $filterContainer.find('.filter-comparator')
      valueContainer = $filterContainer.find('.filter-value-container')
      if options
        filterComparator.html @_htmlForComparator(options.type)
        valueContainer.html @_inputForFilter(options.values)
      else
        filterComparator.html ""
        valueContainer.html @_inputForFilter("")

    getQuery: ->
      query = {}
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