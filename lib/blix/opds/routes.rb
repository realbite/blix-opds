module Blix
  module OPDS

    module Routes

      OPTIONS = {:accept=>:*, :force=>:raw, :extension=>false}

      module ClassMethods
        attr_reader :opds_root, :opds_prefix, :opds_options, :opds_url_prefix

        def opds_path
          File.join(@opds_prefix ||'/','*path')
        end

        def opds_routes(options={})
          @opds_options = options

          @opds_prefix = @opds_options[:prefix] || '/'
          @opds_prefix = '/' + @opds_prefix unless @opds_prefix[0]=='/'

          @opds_root   = @opds_options[:root] || raise( 'Missing root path for OPDS catalog file system')
          @opds_url_prefix = @opds_options[:url] || raise( 'Missing url root for OPDS catalog')
          @opds_url_prefix = File.join(@opds_url_prefix, @opds_prefix)

          route 'GET',  opds_path , OPTIONS do
            result  = get_handler.process( path_params[:path])

            if result.is_a?(String)
              add_headers 'content-type'=>'application/atom+xml'
              result 
            elsif result.is_a?(Hash)
              data = File.read( result[:path] )
              send_data data, :type=>result[:mime_type]
            else
              send_error 'not found', 404
            end
          rescue SecurityError
            send_error 'invalid request'
          end

         
        end

      end # ClassMethods
      

      def opds_params(hash)
        @opds_params ||= {}
        @opds_params.merge!(hash)
      end

      def _params
        self.class.opds_options.merge(@opds_params || {})
      end

      def get_handler
        Generator.new(self.class.opds_root, self.class.opds_url_prefix, _params)
      end

      private

      def self.included(mod)
        mod.extend ClassMethods
      end
    end # Routes


  end
end
