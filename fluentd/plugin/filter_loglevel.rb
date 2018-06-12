require 'fluent/filter'

module Fluent
  class ComponentFilter < Filter
    Fluent::Plugin.register_filter('loglevel', self)
    def configure(conf)
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter_stream(tag,es)
	    new_es = MultiEventStream.new 
	    es.each{|time,record|
	    begin
	    	new_record=record.clone
	    	if(record['message'] =~ /^W/)
	    		new_record['severity'] = "warning"
	    		result = new_record
	    	elsif(record['message'] =~ /^E/)
	    		new_record['severity'] = "error"
	    		result = new_record
	    	else   
	    		new_record['severity'] = "info"
	    		result = new_record
	      end	
		    new_es.add(time,result) 
	    end	
	    }
	    new_es
    end
  end
end

