module BarkingIguana
  class CacheAccess
    include Singleton

    # Proxy everything to the cache instance.
    #
    def method_missing(method_name, *args)
      @cache ||= Rails.cache.instance_variable_get("@data")
      @cache.send(method_name, *args)
    end

    class << self
      # Proxy everytning to the singleton instance so we can do eg
      #
      #     BarkingIguana::CacheAccess.get_multi(:foo, :bar)
      #
      def method_missing(method_name, *args)
        instance.send(method_name, *args)
      end

      def rails_configuration
        configuration_file = File.join(RAILS_ROOT) + '/config/memcache.yml'
        configuration = if File.exists?(configuration_file)
          YAML.load(File.read(configuration_file))
        else
          default_memcache_configuration
        end

        [
          :mem_cache_store, {
            :servers => configuration['hosts'],
            :namespace => configuration['namespace'],
          }
        ]
      end

      def default_memcache_configuration
        { 
          :hosts => %W(127.0.0.1:11211),
          :namespace => File.basename(File.expand_path(RAILS_ROOT)))
        }
      end
    end
  end
end