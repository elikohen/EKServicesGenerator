##################################
# Protocol class
##################################
class Protocol
  # Java event to call on Service send methods
  attr_accessor :onSend
  @onSend=nil
  # Java event to call on Service receive methods
  attr_accessor :onReceive
  @onReceive=nil
  # Java event to call on Service error methods
  attr_accessor :onError
  @onError=nil
  # Java event to call on Service Task resolved method
  attr_accessor :onTask
  @onTask=nil
  attr_accessor :messages
  @messages=nil
  attr_accessor :types
  @messages=nil
  attr_accessor :services
  @services=nil

  def coreDataTypes
    result = Array.new
    types.each do |type|
      if(type.onCoreData)
        result << type
      end
    end
    return result
  end
end