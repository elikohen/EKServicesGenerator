##################################
# Field class
##################################
class Field
  
  attr_accessor :parentName
  @parentName=nil
  attr_accessor :name
  @name=nil
  attr_accessor :type
  @type=nil
  attr_accessor :description
  @description=nil
  attr_accessor :mimeType
  @mimeType=nil

  def typeIOSDAO
    puts 'pidiendo el dao de ios'
    if type.index('DTO')
      return baseTypeSingular().gsub('DTO','DAO')
    end
    return baseTypeSingular()+'DAO'
  end
  def typeJavaDAO
    if type.index('DTO')
      return baseTypeSingular().gsub('DTO','DAO')
    end
    return baseTypeSingular()+'DAO'
  end
  
  def nameFullUcase
    return name.upcase
  end
  def javaName
    return name.camelize()[0..1].downcase<<name.camelize()[2..-1]
  end
  def iosName
    iosname = name
    if(iosname == 'id' && parentName)
      aux = parentName.downcase
      aux = aux.gsub("dto", "")
      iosname = aux+"Id"
      return iosname
    elsif(iosname == 'id')
      return 'objectId'
    end
    return iosname.camelize()[0..1].downcase<<name.camelize()[2..-1]
  end
  def iosCustomGetter
    javaname = self.javaName
    if(javaName.start_with?('new'))
      getter = 'get'+javaname[0].upcase+javaname[1..-1]
      return ", getter=#{getter}"
    end
    return ""
  end
  def nameUcase
    return name.camelize()
  end
  
  def isString
    return baseTypeSingular()=="String"
  end
  
  def isBoolean
    return baseTypeSingular()=="Boolean"
  end
  

  def isInteger
    return baseTypeSingular()=="Integer"
  end
  
  def isLong
    return baseTypeSingular()=="Long"
  end
  
  def isFloat
    return baseTypeSingular()=="Float"
  end
  
  def isDouble
    return baseTypeSingular()=="Double"
  end

  def isFile
    return type=="file"
  end
  
  def baseTypeSingular
    mappings={
      
      "Integer"=>"Integer","integer"=>"Integer","int"=>"Integer",
      "Integer*"=>"Integer","integer*"=>"Integer","int*"=>"Integer",
      
      "Float"=>"Float","float"=>"Float",
      "Float*"=>"Float","float*"=>"Float",
      
      "Double"=>"Double","double"=>"Double",
      "Double*"=>"Double","double*"=>"Double",
      
      "String"=>"String","string"=>"String",
      "String*"=>"String","string*"=>"String",
      
      "Boolean"=>"Boolean","boolean"=>"Boolean",
      "Boolean*"=>"Boolean","boolean*"=>"Boolean",
     
      "Date"=>"String","date"=>"String", 
      "Date*"=>"String","date*"=>"String",      
      
      "Long"=>"Long","long"=>"Long",
      "Long*"=>"Long","long*"=>"Long",
    }
      if(mappings.has_key?type)
        return mappings[type]
      end

    if(type.index('*'))
      return type[0..-2]
    end
    return type
  end
  
  def isBase
    if(["Integer","Boolean","Float","Double","String","Long"].index(typeJava()))
      return true
    end
    return false
  end
  
  def isBaseArray
    if(["List<Integer>","List<Boolean>","List<Float>","List<Double>","List<String>","List<Long>"].index(typeJava()))
      return true
    end
    return false
  end
  
  def isObject
    if(!isBase() && !isBaseArray() && !type.index('*'))
      return true
      end
    return false
  end
  
  def isObjectArray
    if(!isBase() && !isBaseArray() && type.index('*'))
      return true
      end
    return false
  end
    
  def typeJava
    
     mappings={

        "Integer"=>"Integer","integer"=>"Integer","int"=>"Integer",
        "Integer*"=>"List<Integer>","integer*"=>"List<Integer>","int*"=>"List<Integer>",

        "Float"=>"Float","float"=>"Float",
        "Float*"=>"List<Float>","float*"=>"List<Float>",

        "Double"=>"Double","double"=>"Double",
        "Double*"=>"List<Double>","double*"=>"List<Double>",

        "String"=>"String","string"=>"String",
        "String*"=>"List<String>","string*"=>"List<String>",

        "Boolean"=>"Boolean","boolean"=>"Boolean",
        "Boolean*"=>"List<Boolean>","boolean*"=>"List<Boolean>",

        "Date"=>"String","date"=>"String",
        "Date*"=>"List<String>","date*"=>"List<String>",  
            
        "Long"=>"Long","long"=>"Long",
        "Long*"=>"List<Long>","long*"=>"List<Long>",
      }
        if(mappings.has_key?type)
          return mappings[type]
        end
    
    if(type.index('*'))
      return 'List<'<<type[0..-2]<<'>'
    end
    return type    
  end
  
  
  
  def typeIOS
    
     mappings={

        "Integer"=>"NSNumber","integer"=>"NSNumber","int"=>"NSNumber",
        "Integer*"=>"NSArray","integer*"=>"NSArray","int*"=>"NSArray",

        "Float"=>"NSNumber","float"=>"NSNumber",
        "Float*"=>"NSArray","float*"=>"NSArray",

        "Double"=>"NSNumber","double"=>"NSNumber",
        "Double*"=>"NSArray","double*"=>"NSArray",

        "String"=>"NSString","string"=>"NSString",
        "String*"=>"NSArray","string*"=>"NSArray",

        "Boolean"=>"NSNumber","boolean"=>"NSNumber",
        "Boolean*"=>"NSArray","boolean*"=>"NSArray",

        "Date"=>"NSDate","date"=>"NSDate",
        "Date*"=>"NSArray","date*"=>"NSArray",  
            
        "Long"=>"NSNumber","long"=>"NSNumber",
        "Long*"=>"NSArray","long*"=>"NSArray",
      }
        if(mappings.has_key?type)
          return mappings[type]
        end
    
    if(type.index('*'))
      return 'NSArray'
    end
    return type    
  end


  def iosBaseTypeSingular
    mappings={

        "Integer"=>"NSNumber","integer"=>"NSNumber","int"=>"NSNumber",
        "Integer*"=>"NSNumber","integer*"=>"NSNumber","int*"=>"NSNumber",

        "Float"=>"NSNumber","float"=>"NSNumber",
        "Float*"=>"NSNumber","float*"=>"NSNumber",

        "Double"=>"NSNumber","double"=>"NSNumber",
        "Double*"=>"NSNumber","double*"=>"NSNumber",

        "String"=>"NSString","string"=>"NSString",
        "String*"=>"NSString","string*"=>"NSString",

        "Boolean"=>"NSNumber","boolean"=>"NSNumber",
        "Boolean*"=>"NSNumber","boolean*"=>"NSNumber",

        "Date"=>"NSDate","date"=>"NSDate",
        "Date*"=>"NSDate","date*"=>"NSDate",

        "Long"=>"NSNumber","long"=>"NSNumber",
        "Long*"=>"NSNumber","long*"=>"NSNumber",
    }
    if(mappings.has_key?type)
      return mappings[type]
    end

    if(type.index('*'))
      return type[0..-2]
    end
    return type
  end

  #TODO: add mappings for relationships (arrays and custom objects)
  def iosBaseTypeCoreData
    mappings={

        "Integer"=>"Integer 64","integer"=>"Integer 64","int"=>"Integer 64",

        "Float"=>"Decimal","float"=>"Decimal",

        "Double"=>"Decimal","double"=>"Decimal",

        "String"=>"String","string"=>"String",

        "Boolean"=>"Boolean","boolean"=>"Boolean", "bool"=>"Boolean",

        "Date"=>"Date","date"=>"Date",

        "Long"=>"Integer 64","long"=>"Integer 64",

    }
    if(mappings.has_key?type)
      return mappings[type]
    end
    
    return nil
  end

end
