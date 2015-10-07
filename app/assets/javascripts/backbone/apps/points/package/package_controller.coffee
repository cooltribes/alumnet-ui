@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
  class Package.Controller
    listPackages: ->
      prizes = AlumNet.request("prize:entities", {})
      page = new Package.ListView
        collection: prizes
      AlumNet.mainRegion.show(page)
      # Check cookies for first visit
      if not Cookies.get('points_visit')
        modal = new Package.ModalPoints
        $('#container-modal-points').html(modal.render().el)
        Cookies.set('points_visit', 'true')
      AlumNet.execute('render:points:submenu',undefined,2,true)

      page.on 'childview:buy', (childView) ->
        prize = childView.model
        attrs = { prize_id: prize.get('id'), user_id: AlumNet.current_user.id, price: prize.get('price'), status: 1, prize_type: prize.get('prize_type'), remaining_quantity: prize.get('quantity') }
        request = AlumNet.request('user_prize:create', attrs)
        request.on 'save:success', (response, options)->
          AlumNet.current_user.profile.fetch
            success: ->
              AlumNet.current_user.fetch
                refresh: true,
                success: ->
                  AlumNet.current_user.trigger "render:points"
                  AlumNet.trigger "points:earned"
                
        request.on 'save:error', (response, options)->
          console.log response.responseJSON