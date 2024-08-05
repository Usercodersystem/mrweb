# frozen_string_literal: true

require_relative "mrweb/version"
require 'net/http'
require 'json'
require 'uri'
require 'cgi'
require_relative 'exceptions'
module Mrweb
  class Error < StandardError; end
  class API
    def initialize(apikey = nil, use_testkey = false, env = false)
      @apikey = apikey
      if use_testkey
        @apikey = 'testkey'
      elsif env
        begin
          @apikey = ENV['MRWEB_APIKEY']
        rescue
          raise EnvError, 'Failed To Get APIKEY From env please Set By Name MRWEB_APIKEY in environ variable name'
        end
      end
    end

    def translate(to, text)
      parms = { 'to' => to, 'text' => text }
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/translate.php?#{URI.encode_www_form(parms)}"))
      result = JSON.parse(api)
      begin
        return result['translate']
      rescue KeyError
        raise APIError, "Translate Error For Lang #{to}"
      end
    end

    def ocr(to, url)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/ocr.php?url=#{url}&lang=#{to}"))
      result = JSON.parse(api)
      begin
        return result['result']
      rescue KeyError
        raise APIError, "Error In OCR Lang #{to}"
      end
    end

    def isbadword(text)
      text = CGI.escape("text=#{text}")
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/badword.php?#{text}"))
      result = JSON.parse(api)
      return result['isbadword'] == true
    end

    def randbio
      return Net::HTTP.get(URI('https://mrapiweb.ir/api/bio.php'))
    end

    def isaitext(text)
      text = CGI.escape("text=#{text}")
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/aitext.php?#{text}"))
      result = JSON.parse(api)
      return result['aipercent'] != '0%'
    end

    def notebook(text, savetofile = false, filename = nil)
      text = text.gsub(' ', '-')
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/notebook.php?text=#{text}"))
      if savetofile
        if filename.nil?
          raise Exception, 'Filename Is Required!'
        end
        File.open(filename, 'wb') do |mr|
          mr.write(api)
        end
      else
        return api
      end
    end

    def email(to, subject, text)
      send = "to=#{to}&subject=#{subject}&message=#{text}"
      Net::HTTP.get(URI("https://mrapiweb.ir/api/email.php?#{send}"))
      return "Email Sent To #{to}"
    end

    def ipinfo(ip)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/ipinfo.php?ipaddr=#{ip}"))
      ip = JSON.parse(api)
      begin
        return ip
      rescue
        raise APIError, "Failed To Get This IP Information : #{ip}"
      end
    end

    def insta(link)
      return link.gsub('instagram.com', 'ddinstagram.com')
    end

    def voicemaker(text, sayas = 'man', filename = nil)
      text = text.gsub(' ', '-')
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/voice.php?sayas=#{sayas}&text=#{text}"))
      if filename.nil?
        raise Exception, 'Filename Is Required!'
      end
      File.open(filename, 'wb') do |mr|
        mr.write(api)
      end
      return true
    end

    def imagegen(text)
      apikey = @apikey
      text = text.gsub(' ', '-')
      return Net::HTTP.get(URI("https://mrapiweb.ir/api/imagegen.php?key=#{apikey}&imgtext=#{text}"))
    end

    def proxy
      api = Net::HTTP.get(URI('https://mrapiweb.ir/api/telproxy.php'))
      proxy = JSON.parse(api)
      return proxy['connect']
    end

    def fal(filename)
      api = Net::HTTP.get(URI('https://mrapiweb.ir/api/fal.php'))
      File.open(filename, 'wb') do |mr|
        mr.write(api)
      end
      return true
    end

    def worldclock
      return Net::HTTP.get(URI('https://mrapiweb.ir/api/zone.php'))
    end

    def youtube(vid)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/yt.php?key=#{@apikey}&id=#{vid}"))
      return api
    end

    def sendweb3(privatekey = nil, address = nil, amount = nil, rpc = nil, chainid = nil)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/wallet.php?key=#{privatekey}&address=#{address}&amount=#{amount}&rpc=#{rpc}&chainid=#{chainid}"))
      return api
    end

    def google_drive(link)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/gdrive.php?url=#{link}"))
      drive = JSON.parse(api)
      return drive['link']
    end

    def bing_dalle(text)
      raise EndSupport, 'Bing Dalle Is End Of Support'
    end

    def wikipedia(text)
      return Net::HTTP.get(URI("https://mrapiweb.ir/wikipedia/?find=#{text}&lang=fa"))
    end

    def chrome_extention(id, file)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/chrome.php?id=#{id}"))
      File.open(file, 'wb') do |f|
        f.write(api)
      end
    end

    def fakesite(site)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/fakesite.php?site=#{site}"))
      return JSON.parse(api)['is_real']
    end

    def webshot(site, filesave)
      apikey = @apikey
      api1 = Net::HTTP.get(URI("https://mrapiweb.ir/api/webshot.php?key=#{apikey}&url=#{site}&fullSize=false&height=512&width=512"))
      begin
        File.open(filesave, 'wb') do |f|
          f.write(api1)
        end
      rescue
        return api1
      end
    end

    def barcode(code)
      apikey = @apikey
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/barcode.php?key=#{apikey}&code=#{code}"))
      begin
        return JSON.parse(api)['result']
      rescue
        return JSON.parse(api)['message']
      end
    end

    def domain_check(domain)
      api = JSON.parse(Net::HTTP.get(URI("https://mrapiweb.ir/api/domain.php?domain=#{domain}")))
      return api
    end

    def qr(texturl, action = 'encode', savefile = true)
      if action == 'encode'
        text = "action=#{action}&text=#{texturl}"
        api = Net::HTTP.get(URI("https://mrapiweb.ir/api/qr/qrcode.php?#{text}"))
        if savefile
          File.open('qr.png', 'wb') do |f|
            f.write(api)
          end
        else
          return api
        end
      else
        text = "action=#{action}&url=#{texturl}"
        api = Net::HTTP.get(URI("https://mrapiweb.ir/api/qr/qrcode.php?#{text}"))
        return api
      end
    end
  end
  class AI
    def initialize
      @version = "1.7"
    end
    
    def bard(query)
      begin
        result = Net::HTTP.get(URI.parse("https://mrapiweb.ir/bardai/ask?text=#{URI.encode_www_form_component(query)}"))
        return result
      rescue Exception => er
        raise AIError.new("Failed To Get Response From Bard", er)
      end
    end
    
    def gpt(query)
      query = URI.encode_www_form_component(query)
      begin
        return Net::HTTP.get(URI.parse("https://mrapiweb.ir/ai/?#{query}"))
      rescue Exception => er
        raise AIError.new("Failed To Get Answer. Make Sure That You Are Connected To Internet & VPN is off", nil)
      end
    end
    
    def evilgpt(query)
      raise EndSupport.new("EvilGPT Is End Of Support", nil)
    end
    
    def gemini(query)
      query = URI.encode_www_form_component(query)
      api = Net::HTTP.get(URI.parse("https://mrapiweb.ir/api/geminiai.php?#{query}"))
      begin
        return api
      rescue
        raise AIError.new("No Answer Found From Gemini. Please Try Again!", nil)
      end
    end
    
    def codeai(query)
      query = URI.encode_www_form_component(query)
      api = Net::HTTP.get(URI.parse("https://mrapiweb.ir/api/aiblack.php?#{query}"))
      begin
        return api
      rescue
        raise AIError.new("No Answer Found From CodeAI. Please Try Again!", nil)
      end
    end
    
    def gemma(query)
      query = URI.encode_www_form_component(query)
      api = Net::HTTP.get(URI.parse("https://mrapiweb.ir/chatbot/newrouter.php?#{query}"))
      begin
        return api
      rescue
        raise AIError.new("No Answer Found From Gemma. Please Try Again!", nil)
      end
    end
    
    def zzzcode(prompt, language = "python", mode = "normal")
      begin
        query = URI.encode_www_form({ "question" => prompt, "lang" => language, "mode" => mode })
        return Net::HTTP.get(URI.parse("https://mrapiweb.ir/chatbot/zzzcode.php?#{query}"))
      rescue
        raise AIError.new("No Answer Found From Zzzcode. Please Try Again!", nil)
      end
    end
  end
  class FAKEMAIL
    def initialize
      @version = "1.7"
    end
  
    def create
      response = Net::HTTP.get(URI("https://mrapiweb.ir/api/fakemail.php?method=getNewMail"))
      JSON.parse(response)["results"]["email"]
    end
  
    def getmails(email)
      response = Net::HTTP.get(URI("https://mrapiweb.ir/api/fakemail.php?method=getMessages&email=#{email}"))
      JSON.parse(response)["results"]
    end
  end
  class HashCheck
    def initialize
      @version = "1.7"
    end
  
    def tron(thash)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/cryptocheck/tron.php?hash=#{thash}"))
      tron = JSON.parse(api)
      return tron
    end
  
    def tomochain(thash)
      api = Net::HTTP.get(URI("https://mrapiweb.ir/api/cryptocheck/tomochain.php?hash=#{thash}"))
      tomo = JSON.parse(api)
      return tomo
    end
  end
  class TRON
    def initialize
      @version = "1.7"
    end
  
    def generate
      api = JSON.parse(Net::HTTP.get(URI("https://mrapiweb.ir/api/tronapi.php?action=genaddress")))
      return api
    end
  
    def balance(address)
      api = JSON.parse(Net::HTTP.get(URI("https://mrapiweb.ir/api/tronapi.php?action=getbalance&address=#{address}")))
      return api["balance"]
    end
  
    def info(address)
      api = JSON.parse(Net::HTTP.get(URI("https://mrapiweb.ir/api/tronapi.php?action=addressinfo&address=#{address}")))
      return api
    end
  
    def send(key, fromadd, to, amount)
      api = JSON.parse(Net::HTTP.get(URI("https://mrapiweb.ir/api/tronapi.php?action=sendtrx&key=#{key}&fromaddress=#{fromadd}&toaddress=#{to}&amount=#{amount}")))
      return api
    end
  end
  
end
