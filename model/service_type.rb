##################################
# Type class
##################################
class ServiceType
  attr_accessor :dbMode
  @dbMode=nil
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

  def iosModelName
    if name.index('DTO')
      cdata_name=name.gsub('DTO','CD')
      return cdata_name
    end
    cdata_name=name+'CD'
    return cdata_name
  end

  def iosProviderName
    if name.index('DTO')
      provider_name=name.gsub('DTO','Provider')
      return provider_name
    end
    provider_name=name+'Provider'
    return provider_name
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
      if(field.javaName=="responseCode" || field.iosName=="responseCode")
        return true
      end
    end
    return false
  end
  
  def javaInstanceName
    return name.slice(0,1).downcase + name.slice(1..-1)
  end

  def onCoreData
    return dbMode != nil
  end

  def coreDataIdField
    result = "objectId"
    fields.each do |field|
      if(field.name == 'id')
        result = field.iosName
        break
      end
    end
    return result
  end

  def coredataFields
    result = ""
    fields.each do |field|
      if(field.iosBaseTypeCoreData)
        result << ("\t\t<attribute name=\""+field.iosName+"\" optional=\"YES\" attributeType=\""+field.iosBaseTypeCoreData+"\" syncable=\"YES\"/>\n")
      end
    end
    return result
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
