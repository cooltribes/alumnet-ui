@AlumNet.module 'BusinessExchangeApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
  class Profile.BusinessProfiles extends Marionette.CompositeView
    template: 'business_exchange/main/templates/profiles_container'
    childView: AlumNet.BusinessExchangeApp.Shared.Profile
    childViewContainer: '.profiles-container'

    ui:
      'loading': '.throbber-loader'

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreBusinessProfiles')
      $(window).scroll(@loadMoreBusinessProfiles)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreBusinessProfiles: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'business:reload'