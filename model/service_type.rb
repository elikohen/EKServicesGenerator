##################################
# Type class
##################################
class ServiceType
  attr_accessor :name
  @name
  attr_accessor :type
  @type
  attr_accessor :fields
  @fields
  def daoClassName
    if name.index('DTO')
      dao_name=name.gsub('DTO','DAO')
      return dao_name
    end
    dao_name=name+'DAO'
    return dao_name
  end
  
  def isMultipart
    fields.each do |field| 
      if(field.type=="file")
        return true
      end
    end
    return false
  end

  def isRawData
    if(!@type)
      return false
    end
    if(@type=='file' || @type == 'raw')
      return true
    end
    return false
  end

  def isResponse
    fields.each do |field|
      if(field.javaName=="responseCode")
        return true
      end
    end
    return false
  end
  
  def javaInstanceName
    return name.slice(0,1).downcase + name.slice(1..-1)
  end
  def baseArrayFields
    returnValues=Array.new
    fields.each do |field|
      if(field.isBaseArray())
        returnValues<<field
      end
    end       
    return returnValues
  end
  def baseFields
    returnValues=Array.new
    fields.each do |field|
      if(field.isBase())
        returnValues<<field
      end
    end       
    return returnValues
  end
  def objectFields
    returnValues=Array.new
    fields.each do |field|
      if(field.isObject())
        returnValues<<field
      end
    end       
    return returnValues
  end
  def objectArrayFields
    returnValues=Array.new
    fields.each do |field|
      if(field.isObjectArray())
        returnValues<<field
      end
    end       
    return returnValues
  end
end
