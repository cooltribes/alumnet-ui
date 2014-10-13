@Profinda.module "HeaderApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.EmptyNotifications extends App.Views.ItemView
    template: 'header/show/templates/empty_notifications'
    tagName: 'li'

  class Show.Notification extends App.Views.ItemView
    template: 'header/show/templates/notification'
    tagName: 'li'

    className: ->
      @model.get('status')

    events:
      'click' : 'onNotificationClicked'

    serializeData: ->
      _.extend super(),
         markdowned_body: App.Helpers.markdown @model.get('body'),
           no_links: true

    onNotificationClicked: (e) ->
      e.preventDefault()
      @trigger 'notification:clicked', @model
      @readNotification()

    readNotification: ->
      @model.read()
      @trigger 'close:notifications'

  class Show.Notifications extends App.Views.CollectionView
    itemView: Show.Notification
    itemViewContainer: 'ul'
    tagName: 'ul'
    emptyView: Show.EmptyNotifications

    initialize: (options) ->
      @listenTo @, 'itemview:close:notifications', ->
        @trigger  'notifications:hide'

  class Show.EmptyTip extends App.Views.CompositeView
    template: false
    tagName: 'li'
    className: 'loading blue-bg'

  class Show.Tip extends App.Views.ItemView
    template: 'header/show/templates/profile_progress_tip'
    tagName: 'li'

  class Show.Tips extends App.Views.CollectionView
    itemView: Show.Tip
    emptyView: Show.EmptyTip
    itemViewContainer: 'ul'
    tagName: 'ul'
    ui:
      tip_link: 'a'
      dismiss_tip_link: '.dismiss-tip'
    events:
      'click @ui.dismiss_tip_link': 'dismissTip'
      'click @ui.tip_link': 'closeTips'

    closeTips: ->
      @trigger 'itemview:close:tips'

    dismissTip: (e)->
      e.stopPropagation()
      field_name = $(e.currentTarget).data('field-name')
      App.request 'profile_progress_tips:entity:dismiss', tip_name: field_name
      $(e.target).closest('li').fadeOut("fast")


    initialize: (params) ->
      super(params)
      @on "itemview:close:tips", ->
        @triggerMethod('close:tips')

  class Show.NoAuthHeader extends App.Views.ItemView
    template: 'header/show/templates/unauthenticated'

    ui:
      register_button: "#top_register-bttn"
      nav_content: '.nav-content'
      root_logo: '.logo'

    events:
      "click @ui.register_button": 'registerClick'
      "click .nav-toggle": 'toggleNav'
      "click .forgot-password-link a": 'forgotPassword'
      "submit form#top-login-form": 'signMeIn'
      "click @ui.root_logo": 'redirectRoot'

    forgotPassword: ->
      @toggleNav false
      App.vent.trigger "forgot_password:failed"

    redirectRoot: ->
      App.vent.trigger "default:notauthenticated:init"

    toggleNav: (toggle) ->
      @ui.nav_content.toggleClass('mobile-nav-hidden', toggle)

    registerClick: ->
      @toggleNav false
      App.vent.trigger 'signup:init'

    signMeIn: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(@)
      @model.set(data['user'])
      @model.signIn()
      @toggleNav false

    serializeData: ->
      _.extend super(),
        logo_url: App.request 'get:current_account_logo_url'

  class Show.GetHelpCounter extends App.Views.ItemView
    template: 'header/show/templates/counters/get_help'

    bindings:
      '.unread' : 'unread'

    serializeData: ->
      _.extend super(),
        link: @link
        title: @title

    onRender: ->
      @stickit()

  class Show.AutomatchesCounter extends Show.GetHelpCounter
    link: '#automatches'
    title: I18n.t('site_nav.automatches')

  class Show.AuthHeader extends App.Views.Layout
    template: 'header/show/templates/authenticated'

    ui:
      root_logo: '.logo'
      avatar: '.picture'
      # links
      main_links: '.give-help-link, .get-help-link, .responsive-nav-trigger, ' +
                  '.profile-nav-link, .app-link, .tips-link'
      right_links: '.profile-nav-link, .app-link, .tips-link'
      left_links: '.give-help-link, .get-help-link'
      responsive_nav_link: '.responsive-nav-trigger'
      give_help_link: '.give-help-link'
      get_help_link: '.get-help-link'
      profile_nav_link: '.profile-nav-link'
      notifications_link: '.app-link-messages'
      app_links: '.app-link'
      app_link_lottery: '.app-link-lottery'
      app_link_library: '.app-link-library'
      app_link_dashboard: '.app-link-dashboard'
      tips_link: '.tips-link'
      # data
      sub_nav_data_all: '.sub-nav-data, .search-header-data'
      sub_nav_data_right: '.profile-nav-data, .notifications-data, .tips-data'
      sub_nav_data_left: '.give-help-data, .get-help-data'
      give_help_data: '.give-help-data'
      get_help_data: '.get-help-data'
      right_nav_data: '.right-nav-data'
      profile_nav_data: '.profile-nav-data'
      notifications_data: '.notifications-data'
      tips_data: '.tips-data'
      search_header_data: '.search-header-data'
      mobile_tips_link_data: '.mobile-tips-link-data'
      # close navigation on mobile onClick
      mobile_close_nav_triggers: '.sub-nav-data a:not(.app-link-messages), ' +
                                 '.profile-nav-data a'

    regions:
      notificationsRegion: "#notification_menu_region"
      tipsRegion: "#tips_region"
      live_help_counter_region: '#live_help-counter'
      automatches_counter_region: '#automatches-counter'
      header_search_region: '.header-search-region'

    events:
      "click @ui.give_help_link": 'showGiveHelpLinks'
      "click @ui.get_help_link": 'showGetHelpLinks'
      "click @ui.profile_nav_link": 'showProfileLinks'
      "click @ui.responsive_nav_link": 'showResponsiveNav'
      "click @ui.app_link_lottery": 'showLottery'
      "click @ui.app_link_library": 'showLibrary'
      "click @ui.app_link_dashboard": 'showDashboard'
      "click @ui.notifications_link": 'onNotificationIconClicked'
      "click @ui.tips_link": 'showProfileProgressTips'
      "click @ui.root_logo": 'redirectRoot'
      "click @ui.mobile_close_nav_triggers": 'hideSubNav'

    bindings:
      'span.nav-count span':
        observe: 'unread_count'
        onGet: 'unreadCountChange'
      '.picture':
        observe: 'picture'
        updateMethod: 'html'
        onGet: 'pictureChange'
      '.progress_completion':
        observe: 'progress_completion'
        updateMethod: 'html'
        onGet: 'progressCompletionChange'

    progressCompletionChange: (val, opts) ->
      I18n.t('site_nav.profile_completion_html', percent: val)

    unreadCountChange: (val, opts) ->
      if parseInt(val) > 0
        @ui.notifications_link.addClass('attention')
      else
        @ui.notifications_link.removeClass('attention')
      val

    pictureChange: (val, opts) ->
      $('<img>').attr 'src', val.picture?.small.url if val

    redirectRoot: ->
      App.vent.trigger "default:authenticated:init"

    initialize: (options) ->
      @listenTo @, 'notifications:icon:close', @toggleNotificationIcon

    onShow: ->
      @$('select.site-nav-category').select2
        adaptDropdownCssClass: (clazz)-> clazz

    showGiveHelpLinks: ->
      @toggleNav @ui.give_help_link, @ui.give_help_data, 'left'

    showGetHelpLinks: ->
      @toggleNav @ui.get_help_link, @ui.get_help_data, 'left'

    showProfileLinks: ->
      @toggleNav @ui.profile_nav_link, @ui.profile_nav_data, 'right'

    showResponsiveNav: ->
      # TODO: check responsivness after I move search-related ui
      #       from here / ui.search_and_completion_data
      @toggleNav @ui.responsive_nav_link,
        [@ui.search_header_data, @ui.mobile_tips_link_data, @ui.right_nav_data]

    showLottery: ->
      App.vent.trigger "lottery:init"
      @toggleNav @ui.app_link_lottery, null, 'right'

    showLibrary: ->
      App.commands.execute 'library_doc:index'
      @toggleNav @ui.app_link_library, null, 'right'

    showDashboard: ->
      App.commands.execute "dashboard:show"
      @toggleNav @ui.app_link_dashboard, null, 'right'

    toggleNav: (navigation_link, navigation_data, side=null) ->
      # show data if link is not active already (otherwise hide)
      # if no navigation_data provided we only highlight (link) but never
      # hide (data/link) as there is no data
      show_data = not navigation_link.hasClass('active') or not navigation_data

      if @isSmallScreen()  # on narrow screen hide all data and links
        @hideSubNav()
      # if wide screen hide only links/data of same side as target
      else if side == 'right'
        @ui.right_links.removeClass('active')
        @ui.sub_nav_data_right.removeClass('active')
      else if side == 'left'
        @ui.left_links.removeClass('active')
        @ui.sub_nav_data_left.removeClass('active')

      if show_data
        navigation_link.addClass('active')  # add highlight to current link
        if _.isArray navigation_data        # show all data if array given
          data.addClass('active') for data in navigation_data
        else
          navigation_data?.addClass('active') # pass null if you want to skip it

      # select previous if nothing selected
      if navigation_data and @ui.right_links.filter('.active').length == 0
        @prev_selected_link?.addClass('active')
      @prev_selected_link = navigation_link unless navigation_data


    showProfileProgressTips: ->
      @toggleNav @ui.tips_link, @ui.tips_data, 'right'

      if @ui.tips_data.hasClass('active')
        tips = App.request 'entities:profile_progress_tips'
        tips_view = new Show.Tips
          collection: tips
        @tipsRegion.show tips_view
        @listenTo tips_view, 'itemview:close:tips', (args) ->
          @showProfileProgressTips()

    toggleNotificationIcon: ->
      @toggleNav @ui.notifications_link, @ui.notifications_data, 'right'

    onNotificationIconClicked: ->
      if @ui.notifications_data.hasClass('active')
        @trigger 'notifications:hide'
      else
        @trigger 'notifications:show'

      @toggleNotificationIcon()

    hideSubNav: ->
      if @isSmallScreen()
        @ui.main_links.removeClass('active')
        @ui.sub_nav_data_all.removeClass('active')

    isSmallScreen: ->
      $('.responsive-nav-trigger').is(':visible')

    onRender: ->
      @stickit()

    serializeData: ->
      _.extend super(),
        logo_url: App.request 'get:current_account_logo_url'
