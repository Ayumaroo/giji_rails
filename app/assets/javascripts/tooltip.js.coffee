[filter, toggle, cookie, cookie_in_use] = [[],[],[],[]]


class Google
###
google.load "search", "2"
google.setOnLoadCallback ->
  google.search.CustomSearchControl.attachAutoCompletion(
    "partner-pub-5734536664385414:5yoeu8-m6ic",
    document.getElementById("q"),
    "cse-search-box"
  )


google_ad_client = "pub-5734536664385414"
google_ad_slot = "8941976442"
google_ad_width = 120
google_ad_height = 90


_gaq = _gaq or []
_gaq.push [ "_setAccount", "UA-16547346-1" ]
_gaq.push [ "_trackPageview" ]
do ->
  ga = document.createElement("script")
  ga.type = "text/javascript"
  ga.async = true
  ga.src = (if "https:" == document.location.protocol then "https://ssl" else "http://www") + ".google-analytics.com/ga.js"
  s = document.getElementsByTagName("script")[0]
  s.parentNode.insertBefore ga, s
###

class Client
  @deploy: ->
    @deploy = -> null

    window.onorientationchange = =>
      $(window).trigger('resize')

    $(window).resize =>
      $(window).trigger('scroll')

    $(document).ready =>
      Client.outframe = $("#outframe")
      Client.navi = new Navi()
      Client.info = new Info()
      Client.info.float()
      $(window).trigger('resize')

      (new SowFeed).check()

  @height: ->
    $(window).height() |
    window.innerHeight |
    document.documentElement.clientHeight |
    document.body.clientHeight

  @width: ->
    phone =
      0:   480
      180: 480
      90:  800
      270: 800
    phone[window.orientation] | $(window).width()

  @object: (id)->
    command =
      document.getElementById |
      document.all
    command?(id)

Client.deploy()

document.client = Client

class Navi
  constructor: ->
    @viewport = $("head meta[name=\"viewport\"]")
    @stylesheet = $('head link[rel="stylesheet"]');

    @pagenavi_fullwidth = Client.outframe.find(".pagenavi")
    @navimode_fullwidth = Client.outframe.find("h2,.turnnavi,.row_all,.mes_admin,.mes_maker,.info,.infosp,.infowolf,.caution,.action_bm")
  
    if @stylesheet.attr("href").match /480.css/ 
      @mode = 480 
    if @stylesheet.attr("href").match /800.css/
      @mode = 800 


  resize: (fold)->
    if fold
      dst_padding  = 110
      dst_pagenavi = 120
    else
      dst_padding  = 11
      dst_pagenavi = 48

    @navimode_fullwidth.css
      paddingLeft: dst_padding
    @pagenavi_fullwidth.css
      paddingLeft: dst_pagenavi

class Info
  constructor: ->
    @outframe = Client.outframe
    @contentframe = $('#contentframe')
    @sayfilter = $("#sayfilter")
    # @notepad = $("#notepad")
    # @notepad.after "<div id=\"notepad_after\" style=\"height:55px\"></div>"

    $(window).scroll @scroll
    $(window).resize @resize
    
  
  float: =>
    unless cookie.layoutfilter > 0
      @outframe[0].className = "outframe_navimode"
      @contentframe[0].className = "contentframe_navileft"

      @sayfilter[0].className = "sayfilterleft"
      @sayfilter[0].style.position = "absolute"
      @sayfilter[0].style.height = "auto"

      ###
      changeFilterCheckBoxPlList 0
      changeFilterCheckBoxTypes 0
      ###
      @sayfilter.tabs()

  resize: =>
    # @sayfilter.height Client.height()
    width = Client.width()
    small = 122 + 80
    fold = false

    switch Client.navi.mode
      when 480
        if      small < width - 462
          info_width  = width - 462
        else if small < width - 350
          info_width  = width - 350
          fold = true
        else
          info_width  = width
      when 800
        gap = 10
        if   gap < width - 770
          info_width  = 190 + (width - 770)/2
        else
          info_width  = 190
          fold = true

    @sayfilter.width info_width
    Client.navi.resize(fold)

    if  @outframe.height() < Client.height()
      @outframe.height Client.height()  


  scroll: =>
    @sayfilter[0].style.top = "#{$(window).scrollTop()}px"
    @sayfilter[0].style.left = 0

class Log

class Filter


class SowFeed
  constructor: ->
    @title = $("title").text()
    @url = document.URL
    return  if  @url.indexOf("vid=") < 0  or  @url.indexOf("#newsay") < 0
    @url = @url.replace(/#newsay/, "&cmd=rss")

  to_date: (str)->
    date = new Date()
    if str.match(/([0-9]+)-([0-9]+)-([0-9]+)T([0-9]+):([0-9]+):([0-9]+)/)
      year = parseInt(RegExp.$1, 10)
      month = parseInt(RegExp.$2, 10)
      day = parseInt(RegExp.$3, 10)
      hour = parseInt(RegExp.$4, 10)
      min = parseInt(RegExp.$5, 10)
      sec = parseInt(RegExp.$6, 10)
      date.setYear year
      date.setMonth month
      date.setDate day
      date.setHours hour
      date.setMinutes min
      date.setSeconds sec
      date.setMilliseconds 0
      date.getTime()
    else
      false

  check: ->
    setTimeout =>
      @check_base 0, 0, 0
    , 1000
    $("#newinfo:last > img").show()
  
  check_base: (newDateInt, newFeeds, oldFeeds) ->
    infomes = undefined
    maxDateInt = 0
    $.ajax
      url: @url
      dataType: "xml"
      success: (xml) =>
        $(xml).find("item").each (index, element)=>
          thisTime = $(element).find("date").text()
          thisTime = getElementsByTagName("dc:date")[0].firstChild.nodeValue  if thisTime is ""
          thisDateInt = @to_date(thisTime)

          newDateInt = thisDateInt  if newDateInt is 0
          maxDateInt = thisDateInt  if maxDateInt < thisDateInt
          if newDateInt < thisDateInt
            newFeeds++
          else
            newDateInt = maxDateInt
            false

        if newFeeds > oldFeeds
          newFeeds -= oldFeeds  if $(document).find("#newinfo").size() > 1
          $("title").text "(#{newFeeds}) " + @title
          infomes = newFeeds + " 件の新しい発言があります。"
          if $("#newinfo").size() > 0
            $("#newinfo:last > a").text(infomes).show()
            $("#newinfo:last > img").hide()
            $("#newinfo:last").show()
          oldFeeds = newFeeds

      error: (xhr, status, e) ->

      complete: (xhr, status) =>
        setTimeout =>
          @check_base newDateInt, newFeeds, oldFeeds
        , 5 * 60 * 1000

  more: (link) ->
    href = link.href
    base = $(link).parent()
    base.append $('<img src="img/ajax-loader.gif">')
    $(link).remove()
    $.get href, {}, (data) ->
      mes = $(data).find(".inframe:first").children(":not(h2)")
      setAjaxEvent mes
      base.hide()
      base.after mes
    false

  clear: (link) ->
    href = link.href
    base = $(link).parent()
    base.find("img").show()
    $(link).hide()
    $.get href, {}, (data) ->
      mes = $(data).find(".inframe:first").children(":not(h2,#readmore)")
      setAjaxEvent mes
      base.hide()
      base.before mes
      $("title").text @title.replace(/\(\d+\) /, "")
    false


unpack = (key, filter) ->
  if cookie[key]
    ary = cookie[key].split(",")
    i = 0

    while i < ary.length
      filter[key + "_" + i] = ary[i]
      i++

initFilter = ->
  filter = []
  toggle = []
  cookie = []
  cookie.fixedfilter = -1
  cookie.layoutfilter = -1
  cookie_in_use = []
  cookie_in_use.clipboard = true
  cookie_in_use.cliptext = true
  cookie_in_use.toggle = true
  cookie_in_use.fixedfilter = true
  cookie_in_use.layoutfilter = true
  cookie_in_use.uid = false
  cookie_in_use.pwd = false
  doc_cookie = document.cookie + "; "
  cookies = doc_cookie.split("; ")
  i = 0

  while i < cookies.length
    data = cookies[i].split("=")
    data[1] = ""  unless data[1]
    cookie[data[0]] = data[1]
    i++
  unpack "typefilter", filter
  unpack "pnofilter", filter
  if cookie.toggle
    ary = cookie.toggle.split(",")
    i = 0

    while i < ary.length
      toggle[ary[i]] = 1
      i++
  $("#clipboard").val unescape(cookie.clipboard)  if cookie.clipboard
  $("#cliptext").val unescape(cookie.cliptext)  if cookie.cliptext
  cookie.layoutfilter = 0  if cookie.layoutfilter < 1
  cookie.fixedfilter = 0  if cookie.fixedfilter < 1
  false if cookie.layoutfilter == 0
  fixFilterNoWriteCookie()  if (cookie.fixedfilter == 1) and (cookie.layoutfilter == 1)
  return

writeCookieFilter = ->
  alives = "; expires=Thu, 1-Jan-2030 00:00:00 GMT"
  deletes = "; expires=Thu, 1-Jan-1970 00:00:00 GMT"
  $("#clipboard").each ->
    cookie.clipboard = escape($(this).val())

  $("#cliptext").each ->
    cookie.cliptext = escape($(this).val())

  list = []
  for key of filter
    fhead = key.split("_")
    list[fhead[0]] = []
    cookie_in_use[key] = false
    cookie_in_use[fhead[0]] = true
  for key of filter
    fhead = key.split("_")
    list[fhead[0]][fhead[1]] = filter[key]
  for key of list
    cookie[key] = list[key].join(",")
  cookie.toggle = ""
  for key of toggle
    cookie.toggle += key + ","  if toggle[key] == 1
  for key of cookie
    continue  unless cookie_in_use[key]
    if filter[key]
      expires = deletes
    else
      expires = alives
    document.cookie = key + "=" + cookie[key] + ";path=/" + expires

changeSayDisplays = ->
  $(".message_filter").each ->
    id = @id.split("_")
    mesno = parseInt(id[0])
    logpno = parseInt(id[1])
    mestype = parseInt(id[2])
    display = "block"

    if filter["pnofilter_" + logpno] == 1 or filter["typefilter_" + mestype] == 1
      display = "none"
    else
      msg_key = $(this).find("p:not(.mes_date)").text().length
      b_key = 0
      $(this).find("em").each ->
        b_display = ""
        if filter["typefilter_5"] == 1
          b_display = "none"
          b_key += $(this).text().length + 4
          if msg_key - b_key < 1
            display = "none"
          else
            $(this).next("span").remove()
            $(this).after "<span>/* B.G */</span>"
        else
          b_display = "inline"
          $(this).next("span").remove()
        @style.display = b_display
    @style.display = display

summary = ->
  $("#itemlist").empty()
  ischeckclipseer = 1 != toggle.clipseer
  ischeckclipexecute = 1 != toggle.clipexecute
  ischeckclipagenda = 1 != toggle.clipagenda
  ischeckcliptopix = 1 != toggle.cliptopix
  ischeckclipanchor = 1 != toggle.clipanchor
  ischeckclipbm = 1 != toggle.clipbm
  cliptext = $("#cliptext").val()
  result_list = []
  $(".message_filter").each ->
    link = "#newsay"
    name = "？"
    item = ""
    box = $(this)
    mes = box.find("p:not(.mes_date)")
    text = mes.text()
    if ischeckclipseer
      tseer = text.match("●")
      item += " ●"  if tseer
    if ischeckclipexecute
      texecute = text.match("▼")
      item += " ▼"  if texecute
    if ischeckclipagenda
      tagenda = text.match("■")
      item += " ■"  if tagenda
    if ischeckcliptopix
      ttopix = text.match("【")
      item += " 【】"  if ttopix
    if cliptext
      clipary = cliptext.split(" ")
      i = 0

      while i < clipary.length
        item += " " + clipary[i]  if -1 < text.indexOf(clipary[i])
        i++
    if ischeckclipbm
      box.find(".action_bm .mes_action, .mes_think .action p:not(.mes_date)").each ->
        name = $(this).find("a").text()
        text = $(this).text().replace(name, "")
        item += " " + text
    if ischeckclipanchor
      mes.find(".res_anchor").each ->
        text = $(this).text()
        href = @href
        href = href.replace("#", "&logid=").replace("&move=page", "")  if 0 == text.indexOf(">>")
        item += " <a class=\"res_anchor\" href=\"" + href + "\" target=\"_blank\">" + text + "</a>"
    return  if "" == item
    $(this).find("a[name]").each ->
      link = @name
      name_ary = $(this).text().split(" ")
      name = name_ary[name_ary.length - 1]

    result_list.push "<div class=\"sayfilter_content_enable\"><div class=\"sayfilter_incontent\"><a class=\"res_anchor\" href=\"#" + link + "\">" + name + "</a>" + item + "</div></div> "

  $("#itemlist").append result_list.join("")
tribind_click = (selecter, ary, enable, disable) ->
  button = $(selecter)
  button.click changeButtonTri
  button.each ->
    target = $(this).next().filter("div")
    name = target.attr("id")
    @target = target
    @target_name = name
    @target_var = ary
    @style_enable = enable
    @style_disable = disable
    @set_function = setHeader
    @set_function button, this, ary[name]
headerbind_click = (selecter, ary, enable, disable) ->
  button = $(selecter)
  button.click changeButton
  button.each ->
    target = $(this).next().filter("div")
    name = target.attr("id")
    @target = target
    @target_name = name
    @target_var = ary
    @style_enable = enable
    @style_disable = disable
    @set_function = setHeader
    @set_function button, this, ary[name]
summarybind_click = (selecter, ary, enable, disable) ->
  button = $(selecter)
  name = button.attr("id")
  button.click changeButton
  button.click summary
  button.each ->
    @target_name = name
    @target_var = ary
    @style_enable = enable
    @style_disable = disable
    @set_function = setItem
    @set_function button, this, ary[name]
filterbind_click = (selecter, ary, enable, disable) ->
  button = $(selecter)
  name = button.attr("id")
  button.click changeButton
  button.click changeSayDisplays
  button.each ->
    @target_name = name
    @target_var = ary
    @style_enable = enable
    @style_disable = disable
    @set_function = setFilter
    @set_function button, this, ary[name]
while_bind_click = (head, ary, enable, disable, bind_click) ->
  i = 0

  while i < 99
    id = head + i
    selecter = "#" + id
    button = $(selecter)
    count = button.size()
    if 0 == count
      return  if 0 == i
      continue  if 9 < i
      filter[id] = 2
    else
      filter[id] = 0  unless filter[id] == 1
      bind_click selecter, ary, enable, disable
    i++
changeButtonTri = ->
  button = $(this)
  list = [ 2, 0, 1 ]
  now = @target_var[@target_name]
  list[undefined] = list[0]
  @set_function button, this, list[now]
changeButton = ->
  button = $(this)
  list = [ 1, 0 ]
  now = @target_var[@target_name]
  list[undefined] = list[0]
  @set_function button, this, list[now]
change_pnofilter_all = ->
  id_ary = $(this).attr("id").split("_")
  enabled = id_ary[id_ary.length - 1]

  moveFilterTopZeroIE()
  $(".sayfilter_content div").each ->
    id = @id
    return  if id.indexOf("pnofilter_") < 0
    button = $(this)
    if enabled == 2
      setItem button, this, (if (@target_var[@target_name] == 1) then (0) else (1))
    else
      setItem button, this, enabled

  changeSayDisplays()
  fixFilterLeftIE()
  fixWidth()
setFilter = (button, field, value) ->
  setItem button, field, value
setHeader = (button, field, value) ->
  setItem button, field, value
  if value == 1
    field.target.slideUp "fast"
  else
    field.target.slideDown "fast"
  if value == 2
    field.target.addClass "ie_hover"
  else
    field.target.removeClass "ie_hover"

setItem = (button, field, value) ->
  button.removeClass field.style_enable + " " + field.style_disable
  cookie_in_use[field.target_name] = true
  field.target_var[field.target_name] = value
  if value == 1
    button.addClass field.style_disable
  else
    button.addClass field.style_enable

pumpNumber = ->
  parseInt new Date().getTime() / 1000

closeWindow = ->
  $(".close").toggle (->
    ank = $(this)
    base = ank.parents(".ajax")
    base.fadeOut "nomal", ->
      base.remove()

    false
  ), ->
    ank = $(this)
    base = ank.parents(".ajax")
    base.fadeOut "nomal", ->
      base.remove()

    false

setAjaxEvent = (target) ->
  target.find("p:not(.multicolumn_label):not(.mes_date)").each ->
    html = $(@).html()
    $(@).html( html.replace(///
      (/*)(.*?)(*/|$)
    ///g,'<em>$1$2$3</em>') )

  target.find(".img img").mouseup ->
    name = "？"
    link = ""
    text = ""
    message = $(@).parents(".say").find(".msg")
    message.find("a[name]").each ->
      link = @name
      name_ary = $(@).text().split(" ")
      name = name_ary[name_ary.length - 1]

    message.find(".mes_date").each ->
      ank = $(@).text().match(/¥((.?¥d+)¥)/)[1]
      turn = $(@).attr("turn")
      text = "¥n(>>" + turn + ":" + ank + " " + name + ")"

    $("#clipboard").val $("#clipboard").val() + text

  drag_switch = $("<span> o </span>").addClass("drag_switch")

  target.filter(->
    base = $(@)
    not base.hasClass("ajax")
  ).find(".mes_date").append drag_switch

  target.find(".drag_switch").toggle(->
      drag_switch = $(@)
      base = drag_switch.parents(".message_filter")
      base.css zIndex: pumpNumber()
      $(base).clone(true).css("display", "none").addClass("origin").insertAfter base
      $(base).addClass "drag"
      handlerId = "handler" + pumpNumber()
      handler = $("<h3 id=\"" + handlerId + "\">.</h3>").addClass("handler")
      $(base).prepend handler
      $(base).easydrag()
      $(base).setHandler handlerId
      false
  ,->
      name = $(@)
      base = name.parents(".message_filter")
      base.nextAll(".origin").fadeIn()
      base.fadeOut "nomal", ->
        base.remove()

      false
  )

  target.find(".res_anchor").toggle ((mouse) ->
    ank = $(this)
    base = ank.parents(".message_filter")
    text = ank.text()
    title = ank.attr("title")
    if 0 == text.indexOf(">>")
      if "" == title
        href = @href.replace("#", "&logid=").replace("&move=page", "")
        $.get href, {}, (data) ->
          mes = $(data).find(".message_filter")
          date = $(mes).find(".mes_date")
          base.after mes

          topm = mouse.pageY + 16
          leftm = mouse.pageX - 100
          leftend = $("body").width() - mes.width() - 8
          leftm = leftend  if leftend < leftm
          mes.css
            top: topm
            left: leftm
            zIndex: pumpNumber()

          mes.addClass("ajax").css "display", "none"
          $(mes).fadeIn()
          handlerId = "handler" + pumpNumber()
          handler = $("<div id=\"" + handlerId + "\">.</div>").addClass("handler")
          $(mes).prepend handler
          $(mes).easydrag()
          $(mes).setHandler handlerId
          close = $("<span> x </span>").addClass("close")
          date.append close
          closeWindow()
          setAjaxEvent mes
      else
        window.open @href, "_blank"
        return false
    else
      window.open @href, "_blank"
      return false
    false
  ), (mouse) ->
    ank = $(this)
    base = ank.parents(".message_filter")
    base.nextAll(".ajax").fadeOut "nomal", ->
      base.nextAll(".ajax").remove()

    false

deploySayFilter = ->
  setAjaxEvent $(".message_filter")
  getSowFeedUrl()
  initFilter()
  headerbind_click ".header", temp_toggle, "sayfilter_heading", "sayfilter_heading"
  headerbind_click "#filter_header", toggle, "sayfilter_heading", "sayfilter_heading"
  headerbind_click "#notepad_header", toggle, "sayfilter_heading", "sayfilter_heading"
  while_bind_click "livetypecaption_", toggle, "sayfilter_caption_enable", "sayfilter_caption_disenable", tribind_click
  while_bind_click "pnofilter_", filter, "sayfilter_content_enable", "sayfilter_content_disenable", filterbind_click
  filterbind_click "#pnofilter_-1", filter, "sayfilter_content_enable", "sayfilter_content_disenable"
  tribind_click "#mestypefiltercaption", toggle, "sayfilter_caption_enable", "sayfilter_caption_disenable"
  headerbind_click "#lumpfiltercaption", toggle, "sayfilter_caption_enable", "sayfilter_caption_disenable"
  $(".sayfilter_button_lump").click change_pnofilter_all
  headerbind_click "#textnotepadcaption", toggle, "sayfilter_caption_enable", "sayfilter_caption_disenable"
  headerbind_click "#itempickercaption", toggle, "sayfilter_caption_enable", "sayfilter_caption_disenable"
  headerbind_click "#adcaption", toggle, "sayfilter_caption_enable", "sayfilter_caption_disenable"
  while_bind_click "typefilter_", filter, "sayfilter_content_enable", "sayfilter_content_disenable", filterbind_click
  summarybind_click "#clipbm", toggle, "sayfilter_content_enable", "sayfilter_content_disenable"
  summarybind_click "#clipanchor", toggle, "sayfilter_content_enable", "sayfilter_content_disenable"
  summarybind_click "#clipseer", toggle, "sayfilter_content_enable", "sayfilter_content_disenable"
  summarybind_click "#clipexecute", toggle, "sayfilter_content_enable", "sayfilter_content_disenable"
  summarybind_click "#clipagenda", toggle, "sayfilter_content_enable", "sayfilter_content_disenable"
  summarybind_click "#cliptopix", toggle, "sayfilter_content_enable", "sayfilter_content_disenable"
  $("#cliptext").change summary
  $("#cliptext").keyup (code) ->
    summary()  if code == 13

  $("#cliptext").show()
  changeSayDisplays()
  summary()

temp_toggle = []


