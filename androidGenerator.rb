# androidGenerator.rb
class AndroidGenerator
  def generate(protocol,projectName,packageName,aVersion,aOutput,mode)
    puts 'Android Generation'
    puts '------------------'
    ###################################
    # ANDROID GENERATION
    ###################################
    parameters=Hash.new
    parameters['projectName']=projectName
    parameters['packagename']=packageName
    parameters['version']="1.0"
    parameters['dtos']=protocol.types
    parameters['version']=aVersion if aVersion
    parameters['fyMode']=1 if (mode && mode=='fonyou')

    ############ DTO-BUNDLE generation (Base DTOs)
    puts 'DTOs'
    puts '-------------'

    baseDTODir=aOutput+'/'+packageName.gsub('.','/')+"/model/dto/base/"
    FileUtils.mkdir_p(baseDTODir)

    puts "\tCreating Utils ... \t FyResponse"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/model/dto/FyResponse.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/FyResponse.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) } unless File.exists?(helperFile)

    baseDTOFile=baseDTODir+'/'+projectName+"DTOBundle.java"
    puts "\tCreating Base DTO Bundle... \t#{projectName}DTOBundle"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/android_base_dto_bundle.mustache").read,parameters)
    File.open(baseDTOFile, 'w') { |file| file.write(res) }

    ############ Extended DTOs (Extended DTOs)
    dtoDir=aOutput+'/'+packageName.gsub(".",'/')+"/model/dto/"
    FileUtils.mkdir_p(dtoDir)
    protocol.types.each do |type|
      puts "\tCreating DTO ... \t#{type.name}"
      dtoFile=dtoDir+'/'+type.name+'.java'
      parameters['className']=type.name
      res=Mustache.render(File.open("templates/android/"+aVersion+"/android_base_dto.mustache").read,parameters)
      File.open(dtoFile, 'w') { |file| file.write(res) }  unless File.exist?dtoFile
    end

    if(aVersion && aVersion == "1.0")
        ############ DAO generation
        daoDir=aOutput+'/'+packageName.gsub('.','/')+"/model/dao/"
        FileUtils.mkdir_p(daoDir)
        puts 'DAOs'
        puts '-------------'
        protocol.types.each do |type|
          puts "\tCreating DAO ... \t#{type.daoClassName}"
          daoFile=daoDir+'/'+type.daoClassName+'.java'
          parameters['entity']=type
          res=Mustache.render(File.open("templates/android/"+aVersion+"/android_dao.mustache").read,parameters)
          File.open(daoFile, 'w') { |file| file.write(res) }
        end
    end



    ########### Services
    puts 'Services'
    puts '--------'
    logicBaseDir=aOutput+'/'+packageName.gsub(".",'/')+"/logic/base"
    logicDir=aOutput+'/'+packageName.gsub(".",'/')+"/logic"
    FileUtils.mkdir_p(logicBaseDir)
    protocol.services.keys.each do |serviceKey|
      puts "\tCreating Service ... \t#{serviceKey}"
      logicBaseFile=logicBaseDir+"/Base"+serviceKey+"Logic.java"
      logicFile=logicDir+'/'+serviceKey+"Logic.java"
      parameters['serviceName']=serviceKey
      parameters['messages']=protocol.services[serviceKey].messages
      parameters['service']=protocol.services[serviceKey];
      res=Mustache.render(File.open("templates/android/"+aVersion+"/android_base_service.mustache").read,parameters)
      File.open(logicBaseFile, 'w') { |file| file.write(res) }
      res=Mustache.render(File.open("templates/android/"+aVersion+"/android_service.mustache").read,parameters)
      File.open(logicFile, 'w') { |file| file.write(res) }      unless File.exists?(logicFile)
    end
    ########## Tasks
    puts 'Tasks'
    puts '-------'
    protocol.services.keys.each do |serviceKey|
      protocol.services[serviceKey].messages.each do |message|
        puts "\tCreating Task ... \t#{message.name}Task"
        taskFileDir=aOutput+'/'+packageName.gsub(".",'/')+"/tasks/"+serviceKey.downcase
        FileUtils.mkdir_p(taskFileDir)
        taskFile=taskFileDir+'/'+message.methodUpperCase+"Task.java"
        parameters['message']=message
        parameters['service']=protocol.services[serviceKey]
        res=Mustache.render(File.open("templates/android/"+aVersion+"/android_tasks.mustache").read,parameters)
        File.open(taskFile,"w"){|file| file.write(res)}
      end
    end
    puts "\tCreating TaskUtil ... \tBetterHttpResponse"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/tasks/BetterHttpResponse.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/better_http_response.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating TaskUtil ... \tBetterHttpResponseImpl"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/tasks/BetterHttpResponseImpl.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/better_http_response_impl.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating TaskUtil ... \tNotifiedHttpRequest"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/tasks/NotifiedHttpRequest.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/notified_http_request.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }


    ######### Utils
    puts 'UTILS'
    puts '--------------'
    FileUtils.mkdir_p(aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/")
    puts "\tCreating Utils ... \t AdditionalICSKeyStoresSSLSocketFactory"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/AdditionalICSKeyStoresSSLSocketFactory.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/AdditionalICSKeyStoresSSLSocketFactory.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \t AdditionalKeyStoresSSLSocketFactory"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/AdditionalKeyStoresSSLSocketFactory.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/AdditionalKeyStoresSSLSocketFactory.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \tCustomSSLSocketFactory"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/CustomSSLSocketFactory.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/CustomSSLSocketFactory.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \t EasySSLSocketFactory"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/EasySSLSocketFactory.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/EasySSLSocketFactory.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \t FakeSocketFactory"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/FakeSocketFactory.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/FakeSocketFactory.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \t FakeTrustManager"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/FakeTrustManager.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/FakeTrustManager.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }  

    puts "\tCreating Utils ... \tHttpClientHelper"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/HttpClientHelper.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/HttpClientHelper.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \tServiceException"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/ServiceException.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/service_exception.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \tServiceExceptionListener"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/ServiceExceptionListener.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/service_exception_listener.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }

    puts "\tCreating Utils ... \t TrivialTrustManager"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/utils/TrivialTrustManager.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/TrivialTrustManager.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) }    

    ############ Helper if needed
    puts 'HELPERS'
    puts '--------------'
    puts "\tCreating Helper ... \t#{projectName}Helper"
    helperFile=aOutput+'/'+packageName.gsub(".",'/')+"/logic/"+projectName+"Helper.java"
    res=Mustache.render(File.open("templates/android/"+aVersion+"/android_helper.mustache").read,parameters)
    File.open(helperFile, 'w') { |file| file.write(res) } unless File.exists?(helperFile)

  end
end