module Fluent
  class CombinationForkOutput < Output
    Fluent::Plugin.register_output('combination_fork', self)

    unless method_defined?(:log)
      define_method(:log) { $log }
    end

    def initialize
      super
    end

    config_param :output_tag,    :string
    config_param :fork_key,      :string
    config_param :fork_value_type, :string, default: 'csv'
    config_param :separator,     :string,  default: ','
    config_param :max_fallback,  :string,  default: 'log'
    config_param :no_unique,     :bool,    default: false
    config_param :output_key,    :string,  default: "output"
    config_param :output_key_prefix, :string,  default: "c"
    config_param :output_value_type, :string,  default: 'key'
    config_param :choice_of_combination, :integer

    def configure(conf)
      super

      fallbacks = %w(skip drop log)
      raise Fluent::ConfigError, "max_fallback must be one of #{fallbacks.inspect}" unless fallbacks.include?(@max_fallback)
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        org_value = record[@fork_key]
        if org_value.nil?
          log.trace "#{tag} - #{time}: skip to fork #{@fork_key}=#{org_value}"
          next
        end
        log.trace "#{tag} - #{time}: try to fork #{@fork_key}=#{org_value}"

        values = []
        case @fork_value_type
        when 'csv'
          values = org_value.split(@separator)
        when 'array'
          values = org_value
        else
          values = org_value
        end

        values = values.uniq unless @no_unique
        values.reject!{ |value| value.to_s == '' }
        if values.length <= @choice_of_combination
          combination = [values].sort
        else
          combination = values.combination(@choice_of_combination).sort
        end
        p combination

        case @output_value_type
        when 'key'
          combination.each do |c|
            log.trace "#{tag} - #{time}: reemit #{@output_key}=#{c} for #{@output_tag}"
            new_record = record.reject{ |k, v| k == @fork_key }
            c.each_with_index do |v,i|
              new_record = new_record.merge("#{@output_key_prefix}_#{i+1}"  => v)
            end
            new_record.merge!(@index_key => i) unless @index_key.nil?
            Engine.emit(@output_tag, time, new_record)
          end
        when 'array'
          combination.each do |c|
            log.trace "#{tag} - #{time}: reemit #{@output_key}=#{c} for #{@output_tag}"
            new_record = record.reject{ |k, v| k == @fork_key }.merge(@output_key => c)
            new_record.merge!(@index_key => i) unless @index_key.nil?
            Engine.emit(@output_tag, time, new_record)
          end
        else
        end
      end
    rescue => e
      log.error "#{e.message}: #{e.backtrace.join(', ')}"
    ensure
      chain.next
    end
  end
end
