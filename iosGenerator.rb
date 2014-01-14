require 'mustache'

class IOSGenerator
  def generate(protocol,project_name,package_name,ios_version,ios_output)
    if(ios_version && ios_version == "1.0")
        generate_1_0(protocol,project_name,package_name,"1.0",ios_output)
    else
        generate_default(protocol,project_name,package_name,ios_version,ios_output)
    end
  end

  def generate_default(protocol,project_name,package_name,ios_version,ios_output)
    #puts protocol.inspect

    puts '-------------------'
    ###################################
    # iOS GENERATION
    ###################################
    parameters=Hash.new
    parameters['projectName']=project_name
    parameters['packagename']=package_name
    parameters['version']='1.1'
    parameters['dtos']=protocol.types
    parameters['version']=ios_version if ios_version

    ############ DTOs
    dto_dir=ios_output+'/gen/Model/DTO'
    FileUtils.mkdir_p(dto_dir)
    puts 'DTOs'
    puts '-------------'
    protocol.types.each do |type|
      puts "\tCreating DTO ... \t#{type.name}"
      dto_header_file=dto_dir+'/'+type.name+'.h'
      dto_implementation_file=dto_dir+'/'+type.name+'.m'
      parameters['className']=type.name
      parameters['dto']=type
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_dto_header.mustache').read,parameters)
      File.open(dto_header_file, 'w') { |file| file.write(res) }
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_dto_implementation.mustache').read,parameters)
      File.open(dto_implementation_file, 'w') { |file| file.write(res) }
    end

    if(!protocol.coreDataTypes.empty?)
      ############ COREDATA
      data_dir=ios_output+'/gen/Model/coredata'
      datamodel_dir = data_dir+"/"+project_name+".xcdatamodeld/"+project_name+".xcdatamodel"
      coreDataTypes = protocol.coreDataTypes
      FileUtils.mkdir_p(datamodel_dir)
      FileUtils.mkdir_p(data_dir+"/providers")
      puts 'CORE DATA'
      puts '-------------'
      parameters['coreDataTypes'] = coreDataTypes
      puts "\tCreating #{project_name}.xcdatamodeld ..."
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_model.mustache').read,parameters)
      File.open(datamodel_dir+"/contents", 'w') { |file| file.write(res) }
      puts "\tCreating CoreDataManager ..."
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_manager_header.mustache').read,parameters)
      File.open(data_dir+"/CoreDataManager.h", 'w') { |file| file.write(res) } unless File.exists?(data_dir+"/CoreDataManager.h")
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_manager_implementation.mustache').read,parameters)
      File.open(data_dir+"/CoreDataManager.m", 'w') { |file| file.write(res) } unless File.exists?(data_dir+"/CoreDataManager.m")
      coreDataTypes.each do |cdType|
        puts "\tCreating CoreDataObject ... \t#{cdType.iosModelName}"
        data_header_file=data_dir+'/'+cdType.iosModelName+'.h'
        data_implementation_file=data_dir+'/'+cdType.iosModelName+'.m'
        parameters['className']=cdType.iosModelName
        parameters['cdType']=cdType
        res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_entity_header.mustache').read,parameters)
        File.open(data_header_file, 'w') { |file| file.write(res) }
        res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_entity_implementation.mustache').read,parameters)
        File.open(data_implementation_file, 'w') { |file| file.write(res) }

        puts "\tCreating Provider ... \t#{cdType.iosProviderName}"
        provider_header_file=data_dir+'/providers/'+cdType.iosProviderName+'.h'
        provider_implementation_file=data_dir+'/providers/'+cdType.iosProviderName+'.m'
        parameters['className']=cdType.iosProviderName
        res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_provider_header.mustache').read,parameters)
        File.open(provider_header_file, 'w') { |file| file.write(res) } ##unless File.exists?(provider_header_file)
        res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_data_provider_implementation.mustache').read,parameters)
        File.open(provider_implementation_file, 'w') { |file| file.write(res) } ##unless File.exists?(provider_implementation_file)
      end
    end

    ############ Response object
    puts 'Response object'
    puts '-------------'
    puts "\tCreating Response ... \tServiceResponse"
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_response_header.mustache').read,parameters)
    File.open(ios_output+'/gen/Model/ServiceResponse.h', 'w') { |file| file.write(res) }
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_response_implementation.mustache').read,parameters)
    File.open(ios_output+'/gen/Model/ServiceResponse.m', 'w') { |file| file.write(res) }

    ########### BASE SERVICES
    base_service_dir=ios_output+'/gen/Logic/Base'
    service_dir=ios_output+'/gen/Logic'
    FileUtils.mkdir_p(base_service_dir)
    puts 'SERVICES'
    puts '--------------'
    protocol.services.keys.each do |serviceKey|
      puts "\tCreating Service ... \t#{serviceKey}"
      service=protocol.services[serviceKey]

      ###### Create Import Table
      imports=Array.new
      service.messages.each do |message|
        imports << message
      end
      parameters['imports']=imports


      service_header_file=service_dir+'/'+serviceKey+'Logic.h'
      service_implementation_file=service_dir+'/'+serviceKey+'Logic.m'

      base_service_header_file=base_service_dir+'/Base'+serviceKey+'Logic.h'
      base_service_implementation_file=base_service_dir+'/Base'+serviceKey+'Logic.m'

      parameters['service']=service
      parameters['serviceName']=serviceKey;
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_base_service_header.mustache').read,parameters)
      File.open(base_service_header_file,'w'){|file| file.write(res)}
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_base_service_implementation.mustache').read,parameters)
      File.open(base_service_implementation_file,'w'){|file| file.write(res)}
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_service_header.mustache').read,parameters)
      File.open(service_header_file,'w'){|file| file.write(res)} unless File.exist?(service_header_file)
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_service_implementation.mustache').read,parameters)
      File.open(service_implementation_file,'w'){|file| file.write(res)} unless File.exists?(service_implementation_file)
    end

    ########### HELPERS
    helper_dir=ios_output+'/gen/Logic'
    FileUtils.mkdir_p(helper_dir)
    puts 'HELPERS'
    puts '--------------'
    if(ios_version && ios_version >= "1.2")
    puts "\tCreating Helper ... \tServiceHelper"
    helper_header_file=helper_dir+'/ServiceHelper.h'
    helper_implementation_file=helper_dir+'/ServiceHelper.m'
    else
      puts "\tCreating Helper ... \t#{project_name}Helper"
      helper_header_file=helper_dir+'/'+project_name+'Helper.h'
      helper_implementation_file=helper_dir+'/'+project_name+'Helper.m'
    end
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_helper_header.mustache').read,parameters)
    File.open(helper_header_file,'w'){|file| file.write(res)}  unless File.exists?(helper_header_file)
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_helper_implementation.mustache').read,parameters)
    File.open(helper_implementation_file,'w'){|file| file.write(res)} unless File.exists?(helper_implementation_file)

    puts "\tCreating ServiceDelegate"
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_task_delegate.mustache').read,parameters)
    File.open(helper_dir+"/ServiceDelegate.h", 'w') { |file| file.write(res) }

    if(ios_version && ios_version >= "1.2")
      puts "\tCreating Helper ... \tConnectionDelegate"
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_connection_delegate_hader.mustache').read,parameters)
      File.open(helper_dir+"/ConnectionDelegate.h", 'w') { |file| file.write(res) }

      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_connection_delegate_implementation.mustache').read,parameters)
      File.open(helper_dir+"/ConnectionDelegate.m", 'w') { |file| file.write(res) }
    end
  end

  def generate_1_0(protocol,project_name,package_name,ios_version,ios_output)
    puts '-------------------'
    ###################################
    # iOS GENERATION
    ###################################
    parameters=Hash.new
    parameters['projectName']=project_name
    parameters['packagename']=package_name
    parameters['version']='1.0'
    parameters['dtos']=protocol.types
    parameters['version']=ios_version if ios_version

    ############ DTOs
    dto_dir=ios_output+'/gen/Model/DTO'
    FileUtils.mkdir_p(dto_dir)
    puts 'DTOs'
    puts '-------------'
    protocol.types.each do |type|
      puts "\tCreating DTO ... \t#{type.name}"
      dto_header_file=dto_dir+'/'+type.name+'.h'
      dto_implementation_file=dto_dir+'/'+type.name+'.m'
      parameters['className']=type.name
      parameters['dto']=type
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_dto_header.mustache').read,parameters)
      File.open(dto_header_file, 'w') { |file| file.write(res) }
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_dto_implementation.mustache').read,parameters)
      File.open(dto_implementation_file, 'w') { |file| file.write(res) }
    end

    ############ DAOs
    dto_dir=ios_output+'/gen/Model/DAO'
    FileUtils.mkdir_p(dto_dir)
    puts 'DAOs'
    puts '-------------'
    protocol.types.each do |type|
      puts "\tCreating DAO ... \t#{type.daoClassName}"
      dao_header_file=dto_dir+'/'+type.daoClassName+'.h'
      dao_implementation_file=dto_dir+'/'+type.daoClassName+'.m'
      parameters['className']=type.daoClassName
      parameters['dto']=type
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_dao_header.mustache').read,parameters)
      File.open(dao_header_file, 'w') { |file| file.write(res) }
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_dao_implementation.mustache').read,parameters)
      File.open(dao_implementation_file, 'w') { |file| file.write(res) }
    end

    ############ Response object
    puts 'Response object'
    puts '-------------'
    puts "\tCreating Response ... \tServiceResponse"
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_response_header.mustache').read,parameters)
    File.open(ios_output+'/gen/Model/ServiceResponse.h', 'w') { |file| file.write(res) }
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_response_implementation.mustache').read,parameters)
    File.open(ios_output+'/gen/Model/ServiceResponse.m', 'w') { |file| file.write(res) }

    ########### BASE SERVICES
    base_service_dir=ios_output+'/gen/Logic/Base'
    service_dir=ios_output+'/gen/Logic'
    FileUtils.mkdir_p(base_service_dir)
    puts 'SERVICES'
    puts '--------------'
    protocol.services.keys.each do |serviceKey|
      puts "\tCreating Service ... \t#{serviceKey}"
      service=protocol.services[serviceKey]

      ###### Create Import Table
      imports=Array.new
      service.messages.each do |message|
        imports << message
      end
      parameters['imports']=imports


      service_header_file=service_dir+'/'+serviceKey+'Logic.h'
      service_implementation_file=service_dir+'/'+serviceKey+'Logic.m'

      base_service_header_file=base_service_dir+'/Base'+serviceKey+'Logic.h'
      base_service_implementation_file=base_service_dir+'/Base'+serviceKey+'Logic.m'

      parameters['service']=service
      parameters['serviceName']=serviceKey;
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_base_service_header.mustache').read,parameters)
      File.open(base_service_header_file,'w'){|file| file.write(res)}
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_base_service_implementation.mustache').read,parameters)
      File.open(base_service_implementation_file,'w'){|file| file.write(res)}
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_service_header.mustache').read,parameters)
      File.open(service_header_file,'w'){|file| file.write(res)} unless File.exist?(service_header_file)
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_service_implementation.mustache').read,parameters)
      File.open(service_implementation_file,'w'){|file| file.write(res)} unless File.exists?(service_implementation_file)
    end

    ########### TASKS
    tasks_dir=ios_output+'/gen/Logic/Tasks'
    FileUtils.mkdir_p(tasks_dir)
    puts 'TASKS'
    puts '--------------'
    protocol.messages.each do |message|
      imports=Array.new
      imports << message.service
      parameters['imports']=imports
      parameters['message']=message
      puts "\tCreating Task ... \t#{message.methodUpperCase}Task"

      task_header_file=tasks_dir+'/'+message.methodUpperCase+'Task.h'
      task_implementation_file=tasks_dir+'/'+message.methodUpperCase+'Task.m'
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_task_header.mustache').read,parameters)
      File.open(task_header_file,'w'){|file| file.write(res)}
      res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_task_implementation.mustache').read,parameters)
      File.open(task_implementation_file,'w'){|file| file.write(res)}
    end

    ########### HELPERS
    helper_dir=ios_output+'/gen/Logic'
    FileUtils.mkdir_p(helper_dir)
    puts 'HELPERS'
    puts '--------------'
    puts "\tCreating Helper ... \t#{project_name}Helper"
    helper_header_file=helper_dir+'/'+project_name+'Helper.h'
    helper_implementation_file=helper_dir+'/'+project_name+'Helper.m'
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_helper_header.mustache').read,parameters)
    File.open(helper_header_file,'w'){|file| file.write(res)}  unless File.exists?(helper_header_file)
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_helper_implementation.mustache').read,parameters)
    File.open(helper_implementation_file,'w'){|file| file.write(res)} unless File.exists?(helper_implementation_file)

    puts "\tCreating TaskDelegate"
    res=Mustache.render(File.open('templates/ios/'+ios_version+'/ios_task_delegate.mustache').read,parameters)
    File.open(helper_dir+"/TaskDelegate.h", 'w') { |file| file.write(res) }
  end
end