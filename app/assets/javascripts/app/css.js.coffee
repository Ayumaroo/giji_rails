class CSS
  constructor: (base)->
    base.css = @
    @params = new Params 'css'
    @params.is_cookie = true
    @params.on = 'hash'

    @h1 = $("#contentframe h1 img")
    @head = $('head')

    @changer = $(".css_changer")
    @changer.html('')
    @changer.append """
      <a data_href="cinema800">煉瓦</a>
      <a data_href="cinema480">480</a>
      ｜
      <a data_href="night800">月夜</a>
      <a data_href="night480">480</a>
      ｜
      <a data_href="star800">蒼穹</a>
      <a data_href="star480">480</a>
      ｜
      <a data_href="wa800">和の国</a>
      <a data_href="wa480">480</a>
    """
    btn = @changer.find("a")
    link.css = @  for link in btn
    btn.click ->
      href = $(@).attr('data_href')
      @css.params.change(href)
      @css.reload()
      false
    @reload()

  reload: ->
    @date = new Date()
    @params.current = OPTION.css_wday[@date.getDay()]

    @move()
    @render()

  render: ->
    if @current.match /480/ 
      @width = 480 
      @h1_width = 458
    if @current.match /800/
      @width = 800 
      @h1_width = 580

    h1_type = OPTION.head_img[@current][ Math.ceil((@date).getTime() / 60*60*12) % 2]
    @h1.attr 'src', "/images/banner/title#{@h1_width}#{h1_type}.jpg"

    stylesheet = @head.find('link[app]');
    if 0 == stylesheet.length
      @head.append """
        <link media="screen" rel="stylesheet" type="text/css" app/>
      """
      stylesheet = @head.find('link[app]');
    stylesheet.attr("href","/stylesheets/#{@current}.css")
    $(window).trigger('resize')

  move: ->
    @current = @params.val()