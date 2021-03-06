class Navi
  constructor: (base)->
    base.navi = @
    @viewport = $("head meta[name=\"viewport\"]")

    @pagenavi_fullwidth = Client.outframe.find(".pagenavi")
    @navimode_fullwidth = Client.outframe.find("""
      h2, h3,
      .turnnavi,
      .row_all,
      .ADMIN,     .MAKER,     .INFONOM, .INFOSP, .INFOWOLF,
      .mes_admin, .mes_maker, .info,    .infosp, .infowolf,
      .caution,
      .action_bm
    """)
  


  resize: (fold)->
    if fold
      dst_padding  = fold
      dst_pagenavi = fold + 10
    else
      dst_padding  = 11
      dst_pagenavi = 48

    @navimode_fullwidth.css
      paddingLeft: dst_padding
    @pagenavi_fullwidth.css
      paddingLeft: dst_pagenavi
