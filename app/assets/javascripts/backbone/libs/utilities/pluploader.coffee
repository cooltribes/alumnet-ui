@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->

  class Utilities.Pluploader
    constructor: (selector, view)->
      uploader = new plupload.Uploader
        browse_button: selector
        url: AlumNet.api_endpoint + '/pictures/'
        headers:
          'Authorization': 'Token token="' + AlumNet.current_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'
        filters:
          mime_types:[
            title: "Images Files"
            extensions: "jpg,png,gif,jpeg"            
          ]
          
      uploader.bind 'FilesAdded',(up, files)->
        html = ''
        lengthFile = files.length 
        plupload.each files, (file, i)->
          #html = html + "<div class='col-md-4' id=#{file.id}> #{file.name} (#{plupload.formatSize(file.size)}) <b></b> </div>"
          if i == lengthFile - 1
            html = html + "<div class='col-md-3 text-center' id=#{file.id}>
              <div class='previewImage'>
                <span class='throbber-loader'></span><br><b></b> 
              </div>
            </div> <hr>"
          else
            html = html + "<div class='col-md-3 text-center' id=#{file.id}>
              <div class='previewImage'>
                <span class='throbber-loader'></span><br><b></b> 
              </div>
            </div>"
          
        view.ui.fileList.html(html)
        uploader.start()

      uploader.bind 'fileUploaded', (up, file, response)->
        if response.status == 201
          picture = JSON.parse(response.response)
          view.picture_ids.push picture.id

      uploader.bind 'UploadProgress', (up, file) ->
        view.$el.find("div##{file.id}").find('b').html('<span>' + file.percent + "%</span>")

      @uploader = uploader

  class Utilities.PluploaderAlbums
    constructor: (browse_trigger, view)->
      uploader = new plupload.Uploader
        browse_button: browse_trigger
        url: AlumNet.api_endpoint + '/albums/' + view.model.id + "/pictures"
        headers:
          'Authorization': 'Token token="' + AlumNet.current_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'
        filters:
          mime_types:[
            title: "Images Files"
            extensions: "jpg,png,gif"            
          ]

        
        # multipart_params

      uploader.bind 'FilesAdded',(up, files)->
        # html = ''
        #Add loading bar...
        modelAdded = view.collection.add({})         
        view.pictures_ids.push modelAdded
        # view.collection.last..attr("src", e.target.result)

        # plupload.each files, (file)->
        #   reader = new FileReader()
        #   reader.onload = (e)->
        #     imgUrl = 
        #       card: e.target.result

        #     lastPic = view.collection.last()
        #     # console.log lastPic
        #     # lastPic.set("picture", imgUrl)
        #     # lastPic.trigger "change"
        #   # console.log file.getSource().getSource()
        #   # console.log file
          
        #   #Read each file from local computer
        #   reader.readAsDataURL(file.getSource().getSource())



          # html = html + "<li id=#{file.id}> #{file.name} (#{plupload.formatSize(file.size)}) <b></b> </li>"
        # view.ui.fileList.html(html)
        uploader.start()
            
      uploader.bind 'UploadComplete', ()->
        #Remove the img with "Uploading .." message        
        view.collection.pop()

      uploader.bind 'fileUploaded', (up, file, response)->
        if response.status == 201
          # console.log "Upladed a file"
          # console.log response
          # lastPic = view.collection.last()
          #Get the last index of the
          lastIndex = view.collection.length - 1
          view.collection.add JSON.parse(response.response),
            at: lastIndex
          # console.log modelo  
          # lastIndex = view.collection.indexOf(view.collection.last())
          # console.log "lastindex" + lastIndex
          # console.log "length" + view.collection.length
          # picture = JSON.parse(response.response)
          # view.picture_ids.push picture.id 
      @uploader = uploader

  class Utilities.PluploaderFolders
    constructor: (browse_triggers, view)->
      uploader = new plupload.Uploader
        browse_button: browse_triggers
        url: AlumNet.api_endpoint + '/folders/' + view.model.id + "/attachments"
        headers:
          'Authorization': 'Token token="' + AlumNet.current_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'
       
       
      uploader.bind 'FilesAdded',(up, files)->
        
        if view.checkDuplicated(files)
          #Add loading bar...
          view.showUploading()  
          uploader.start()
            
      uploader.bind 'UploadComplete', ()->
        view.hideUploading()

      uploader.bind 'fileUploaded', (up, file, response)->
        if response.status == 201
        
          lastIndex = view.collection.length - 1
          view.collection.add JSON.parse(response.response),
            at: lastIndex
       
      @uploader = uploader