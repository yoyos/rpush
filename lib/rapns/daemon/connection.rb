module Rapns
  module Daemon
    class Connection
      def self.connect
        @ssl_context = setup_ssl_context
        @tcp_socket, @ssl_socket = connect_socket
        setup_at_exit_hook
      end

      def self.write(data)
        @ssl_socket.write(data)
        @ssl_socket.flush
      end

      protected

      def self.setup_ssl_context
        ssl_context = OpenSSL::SSL::SSLContext.new
        ssl_context.key = OpenSSL::PKey::RSA.new(Certificate.certificate, '')
        ssl_context.cert = OpenSSL::X509::Certificate.new(Certificate.certificate)
      end

      def self.connect_socket
        tcp_socket = TCPSocket.new(Configuration.host, Configuration.port)
        ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, @ssl_context)
        ssl_socket.sync = true
        ssl_socket.connect
        [tcp_socket, ssl_socket]
      end

      def self.setup_at_exit_hook
        Kernel.at_exit { shutdown_socket }
      end

      def self.shutdown_socket
        @ssl_socket.close if @ssl_socket
        @tcp_socket.close if @tcp_socket
      end
    end
  end
end