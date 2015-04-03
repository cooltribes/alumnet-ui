@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->

  class Utilities.Pluploader
    constructor: (selector, view)->
      uploader = new plupload.Uploader
        browse_button: selector
        url: AlumNet.api_endpoint + '/pictures/'
        headers:
          'Authorization': 'Token token="' + AlumNet.current_token + '"'
          'Accept': 'application/vnd.alumnet+json;version=1'

      uploader.bind 'FilesAdded',(up, files)->
        html = ''
        plupload.each files, (file)->
          html = html + "<li id=#{file.id}> #{file.name} (#{plupload.formatSize(file.size)}) <b></b> </li>"
        view.ui.fileList.html(html)
        uploader.start()

      uploader.bind 'fileUploaded', (up, file, response)->
        if response.status == 201
          picture = JSON.parse(response.response)
          view.picture_ids.push picture.id

      uploader.bind 'UploadProgress', (up, file) ->
        view.$el.find("li##{file.id}").find('b').html('<span>' + file.percent + "%</span>")

      @uploader = uploader