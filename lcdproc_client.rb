module RubyGate
  class LcdSession
    require 'socket'
    attr_accessor :screen, :socket

    def initialize
      screen ="tor_#{Process.gid}"
      socket = TCPSocket.open('127.0.0.1', '13666')
      socket.print('hello')
      version_info = socket.read
      puts version_info
      send_cmd('client_set name tor')
      send_cmd('screen_add ' + screen)
    end

    def send_cmd cmd
      socket.print( "#{cmd}\n")
      socket.read
    end

    def write_line (line_str, l=1)
      send_cmd("widget_add #{screen} lcd_page #{l} string")
      send_cmd("widget_set #{screen} lcd_page  #{l}  1  #{l+1} \"#{line_str}\" ")
    end

    def close_session
      send_cmd("widget_del #{screen} lcd_page ")
      # ???? lcd_cmd('widget_del ' + screen + ' lcd_page' + str(lcd_line_nr))
      # send_cmd('screen_set ' + screen + ' backlight off')
      socket.close()
    end
  end
  class Lcd
    class << self
      def write(message)
        s = LcdSession.new
        lines = message.scan(/.{1,16}/)
        lines.each_with_index do | line_str, l |
          s.write_line(line_str, l)
        end
        sleep(5)
        s.cloe_session         
      end
    end

  end
end 