@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->

  #This is an empty view definition for shared use in most common collection views.
  #Just pass the message you want to show.
  class Utilities.EmptyView extends Marionette.ItemView
    template: 'shared/views/templates/_empty'
  
    initialize: (options)->
      @message = options.message

    templateHelpers: ->
      message: @message 

  #Improved template
  class Utilities.GeneralEmptyView extends Marionette.ItemView
    template: 'shared/views/templates/_betterEmpty'
  
    initialize: (options)->
      @message = options.message

    templateHelpers: ->
      message: @message 