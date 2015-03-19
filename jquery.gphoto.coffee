(($) ->
	$.fn.extend
		gphoto: (options) ->
			settings =
				provider:
					name: 'fotorama'

			settings = $.extend settings, options

			provider =
				fotorama:
					map: (imageUrl, image) ->
						img: "#{imageUrl}w0/"
						thumb: "#{imageUrl}w64-h64/"
					insert: ($link, images) ->
						$fotorama = $('<div class="fotorama"></div>')
						$link.replaceWith($fotorama)
						$fotorama.fotorama $.extend data: images, settings.provider
						return
				ggrid:
					map: (imageUrl, image) ->
						imageUrl: imageUrl
						data: image
					insert: ($link, images) ->
						$ggrid = $('<div class="ggrid"></div>')
						options = data: images
						if $link.attr("title")?
							options['template'] =  $link.attr("title")
						$link.replaceWith($ggrid)
						$ggrid.ggrid $.extend options, settings.provider
						$ggrid.find('a').fluidbox()
						return

			# body script
			return @.filter("[href ^= https\\:\\/\\/plus\\.google\\.com\\/photos]").each () ->
				$link = $(@)
				url = $.url($link.attr('href'))
				userId = url.segment(2)
				albumId = url.segment(4)
				$.getJSON(
					"https://picasaweb.google.com/data/feed/api/user/#{userId}/albumid/#{albumId}?kind=photo&access=public&alt=json-in-script&callback=?",
					(data, status) ->
						images = data.feed.entry.map (image) ->
							$url =  $.url(image.content.src)
							imageUrl = "#{$url.attr('protocol')}://#{$url.attr('host')}#{$url.attr('directory')}"
							provider[settings.provider.name].map(imageUrl, image)
						provider[settings.provider.name].insert($link, images)
						return
				)
) jQuery
