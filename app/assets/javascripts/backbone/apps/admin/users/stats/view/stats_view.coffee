@AlumNet.module 'AdminApp.UserStats', (UserStats, @AlumNet, Backbone, Marionette, $, _) ->

  class UserStats.Layout extends Marionette.LayoutView
    template: 'admin/users/stats/view/templates/layout'

    ui:
      tab_elements: '.js-user-tabs li'

    events:
      'click .js-user-tabs a[rel]' : 'tabClicked'

    regions:
      tab_content_region: '.tab-content-region'

    tabClicked: (e) ->
      tab_name = e.currentTarget.rel
      @ui.tab_elements.removeClass('active')
      $(e.currentTarget).parent().addClass('active')

      @trigger('tab_selected', tab_name)

