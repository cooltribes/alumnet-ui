@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
  class Package.Controller
    listPackages: ->
      prizes = AlumNet.request("prize:entities", {})
      page = new Package.ListView
        collection: prizes
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:points:submenu',undefined,2,true)

      page.on 'childview:buy', (childView) ->
        prize = childView.model
        attrs = { prize_id: prize.get('id'), user_id: AlumNet.current_user.id, price: prize.get('price'), status: 1, prize_type: prize.get('prize_type'), remaining_quantity: prize.get('quantity') }
        request = AlumNet.request('user_prize:create', attrs)
        request.on 'save:success', (response, options)->
          #AlumNet.request('get:current_user')
          AlumNet.current_user.fetch
            refresh: true,
            success: ->
              console.log "user actualizado"
              AlumNet.current_user.profile.fetch
                success: ->
                  AlumNet.trigger "points:earned"
                        
                    #console.log AlumNet.current_user.profile.get('points')
                
        request.on 'save:error', (response, options)->
          console.log response.responseJSON