# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do
  include QuotationdatafilesHelper

  def reply
    render xml: send("response_#{@weixin_message.MsgType}_message", {})
  end
  
    private
    def autoreplay
      job_id =
        Rufus::Scheduler.singleton.in '10s' do
          Rails.logger.info "time flies, it's now #{Time.now}"
          @weixin_message.FromUserName = 'ocUDQt3fXQ6XMLjNhgWMIxB9Ro1w'
          articles = []
          articles << generate_article('title', 'des', qrcodegen, qrcodegen)
          reply_news_message(articles)
        end
      Rails.logger.info "time flies, it's now #{Time.now}" + job_id
    end

    def ggcx_reply rep,l
        resp = optquery('A', rep) 
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】持仓建议", resp, cfg_image_url('optadvise'), nil)
        reply_news_message(articles)
    end

    def mxjs_replay l
        resp = resumeinfo
        l.update(optreplay: resp)
        reply_text_message(resp)

        articles = []
        articles << generate_article("【趋势交易】模型介绍", resp, cfg_image_url('introduce'), nil)
        reply_news_message(articles)
    end

    def zlmy_reply l
        resp = everydaytip
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】至理名言", resp, rand_image_url, nil)
        reply_news_message(articles)
    end

    def jdtj_replay l
        ebook = rand_ebook
        resp = ebook.summary
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】经典阅读", resp, frontcover_url(ebook), nil)
        reply_news_message(articles)
    end

    def gpc_replay l
        resp = allportfolios 'A'
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】股票池", resp, cfg_image_url('account'), get_pub_index_url)
        reply_news_message(articles)
    end

    def czsc_replay l
        resp = helpinfo 
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】操作手册", resp, cfg_image_url('manual'), nil)
        reply_news_message(articles)
    end

    def qrcodetg_replay l
        resp = tginfo 
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】二维码推广", resp, cfg_image_url('qrcodeface'), nil)
        reply_news_message(articles)
    end

    def accountshow_reply l
        resp = account_show 
        l.update(optreplay: resp)

        articles = []
        articles << generate_article("【趋势交易】模型展示", resp, cfg_image_url('accountshow'), get_pub_account_show_url)
        reply_news_message(articles)
    end


    def response_text_message(options={})
      usercheck @weixin_message.FromUserName
      rep = "#{@keyword}".strip
      
      u = User.find_by(openid: @weixin_message.FromUserName)  
      l = u.weixinlogs.build(marketdate: tradedate('A'), openid: @weixin_message.FromUserName, opttime: @weixin_message.CreateTime, optquery: rep)
      l.save
      u.save

      resp = ""
      if rep.length == 6
        ggcx_reply rep, l
      elsif rep.length == 1 
        case rep 
        when '1' 
          mxjs_replay l
        when '2' 
          zlmy_reply l
        when '3' 
          accountshow_reply l
        when '4' 
          gpc_replay l
        when '5' 
          qrcodetg_replay l
        when '66' 
          jdtj_replay l
        else
          czsc_replay l
        end
      end


      #reply_text_message(@weixin_message.FromUserName)
      #reply_text_message("Your Message: #{@keyword}")
    end

    # <Location_X>23.134521</Location_X>
    # <Location_Y>113.358803</Location_Y>
    # <Scale>20</Scale>
    # <Label><![CDATA[位置信息]]></Label>
    def response_location_message(options={})
      @lx    = @weixin_message.Location_X
      @ly    = @weixin_message.Location_Y
      @scale = @weixin_message.Scale
      @label = @weixin_message.Label
      reply_text_message("Your Location: #{@lx}, #{@ly}, #{@scale}, #{@label}")
    end

    # <PicUrl><![CDATA[this is a url]]></PicUrl>
    # <MediaId><![CDATA[media_id]]></MediaId>
    def response_image_message(options={})
      @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      @pic_url  = @weixin_message.PicUrl  # 也可以直接通过此链接下载图片, 建议使用carrierwave.
      reply_image_message(generate_image(@media_id))
    end

    # <Title><![CDATA[公众平台官网链接]]></Title>
    # <Description><![CDATA[公众平台官网链接]]></Description>
    # <Url><![CDATA[url]]></Url>
    def response_link_message(options={})
      @title = @weixin_message.Title
      @desc  = @weixin_message.Description
      @url   = @weixin_message.Url
      reply_text_message("回复链接信息")
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <Format><![CDATA[Format]]></Format>
    def response_voice_message(options={})
      @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      @format   = @weixin_message.Format
      # 如果开启了语音翻译功能，@keyword则为翻译的结果
      # reply_text_message("回复语音信息: #{@keyword}")
      reply_voice_message(generate_voice(@media_id))
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    def response_video_message(options={})
      @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      # 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。
      @thumb_media_id = @weixin_message.ThumbMediaId
      reply_text_message("回复视频信息")
    end

    def response_event_message(options={})
      event_type = @weixin_message.Event
      send("handle_#{event_type.downcase}_event")
    end

    private

      # 关注公众账号
      def handle_subscribe_event
        #if @keyword.present?
          # 扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送
          #return reply_text_message("扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送, keyword: #{@keyword}")
        #end
        resp = guanzhu(@weixin_message.FromUserName)
        articles = []
        articles << generate_article("【趋势交易】", resp, cfg_image_url('guanzhu'), nil)
        reply_news_message(articles)
      end

      # 取消关注
      def handle_unsubscribe_event
        Rails.logger.info("取消关注")
        reply_text_message quxiaoguanzhu(@weixin_message.FromUserName)
      end

      # 扫描带参数二维码事件: 2. 用户已关注时的事件推送
      def handle_scan_event
        reply_text_message("扫描带参数二维码事件: 2. 用户已关注时的事件推送, keyword: #{@keyword}")
      end

      def handle_location_event # 上报地理位置事件
        @lat = @weixin_message.Latitude
        @lgt = @weixin_message.Longitude
        @precision = @weixin_message.Precision
        reply_text_message("Your Location: #{@lat}, #{@lgt}, #{@precision}")
      end

      # 点击菜单拉取消息时的事件推送
      def handle_click_event
        reply_text_message("你点击了: #{@keyword}")
      end

      # 点击菜单跳转链接时的事件推送
      def handle_view_event
        Rails.logger.info("你点击了: #{@keyword}")
      end

      # 帮助文档: https://github.com/lanrion/weixin_authorize/issues/22

      # 由于群发任务提交后，群发任务可能在一定时间后才完成，因此，群发接口调用时，仅会给出群发任务是否提交成功的提示，若群发任务提交成功，则在群发任务结束时，会向开发者在公众平台填写的开发者URL（callback URL）推送事件。

      # 推送的XML结构如下（发送成功时）：

      # <xml>
      # <ToUserName><![CDATA[gh_3e8adccde292]]></ToUserName>
      # <FromUserName><![CDATA[oR5Gjjl_eiZoUpGozMo7dbBJ362A]]></FromUserName>
      # <CreateTime>1394524295</CreateTime>
      # <MsgType><![CDATA[event]]></MsgType>
      # <Event><![CDATA[MASSSENDJOBFINISH]]></Event>
      # <MsgID>1988</MsgID>
      # <Status><![CDATA[sendsuccess]]></Status>
      # <TotalCount>100</TotalCount>
      # <FilterCount>80</FilterCount>
      # <SentCount>75</SentCount>
      # <ErrorCount>5</ErrorCount>
      # </xml>
      def handle_masssendjobfinish_event
        Rails.logger.info("回调事件处理")
      end

end
