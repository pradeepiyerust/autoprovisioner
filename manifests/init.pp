
#Auto provisioner module

#This file contains Puppet scripts for all the modules that need to be configured in the nodes

class autoprovisioner {
	
	#JDK
	include stdlib		
	class { 'jdk_oracle':
	   version => $::fact_jdk_version,
	   version_update => $::fact_jdk_update,
	   version_build => $::fact_jdk_build,
	   platform => $::fact_jdk_platform,
	}
	exec { "update_java_alternative":
	   command => "/usr/sbin/update-alternatives --install /usr/bin/java java /opt/$::fact_jdk_package/bin/java 20000",
	}
	exec { "update_javac_alternative":
	   command => "/usr/sbin/update-alternatives --install /usr/bin/javac javac /opt/$::fact_jdk_package/bin/javac 20000",
	}
	
	#Git
	include git
	
	#Tomcat
	class { 'tomcat': }
	tomcat::instance { 'tomcat8':
	   catalina_base => "$::fact_tomcat_catalina_home",
	   source_url => $::fact_tomcat_source_url,
	}->
	tomcat::setenv::entry {'tomcat-setenv':
	   config_file => "$::fact_tomcat_catalina_home/bin/setenv.sh",
	   param       => "JAVA_OPTS",
	   value       => "$JAVA_OPTS -Dprofile=$::fact_environment",
	}->
	tomcat::service { 'default': 
	}->
	tomcat::config::server { 'tomcat6':
	   catalina_base => "$::fact_tomcat_catalina_home",
	   port          => '8000',
	}->
	tomcat::config::server::connector { 'tomcat6-http':
	   catalina_base         => "$::fact_tomcat_catalina_home",
	   port                  => '8000',
	   protocol              => 'HTTP/1.1',
	   additional_attributes => {
		 'redirectPort' => '8443'
	  },
	}->
	exec { "stop_tomcat":
	   command => "sh $::fact_tomcat_catalina_home/bin/catalina.sh stop",
	   path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
	}->
	exec { "start_tomcat":
	   command => "sh $::fact_tomcat_catalina_home/bin/catalina.sh start",
	   path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
	}
	
	#Maven
	class { 'maven::maven':
	   version => $::fact_maven_version,
	}

	#Nodejs
	include epel
	include nodejs
	
	#Grunt
	exec { 'install_grunt':
	   command => "npm install -g grunt-cli",
	}
	
	#Sonar
	class { 'sonarqube' :
	   version => $::fact_sonar_version,
	}
	
	#MongoDB
    class {'::mongodb::globals':
       manage_package_repo => true,
       version => "$::fact_mongodb_version",
    }->
    class {'::mongodb::server': }->
    class {'::mongodb::client': }
    mongodb::db { 'beautifulyou': 
       user => "$::fact_mongodb_user",
       password => "$::fact_mongodb_password",
    }
	
	#Jenkins
	class { 'jenkins':
		install_java => false,
	}
	
	jenkins::plugin { 'git': }
	jenkins::plugin { 'git-server': }
	jenkins::plugin { 'git-client': }
	jenkins::plugin { 'git-parameter': }
	jenkins::plugin { 'github': }
	jenkins::plugin { 'github-api': }
	jenkins::plugin { 'github-oauth': }
	jenkins::plugin { 'ghprb': }
	jenkins::plugin { 'ruby': }
	jenkins::plugin { 'powershell': }
	jenkins::plugin { 'screenshot': }
	jenkins::plugin { 'jenkins-jira-issue-updater': }
	jenkins::plugin { 'jira': }
	jenkins::plugin { 'ws-cleanup': }
	jenkins::plugin { 'mongodb': }
	jenkins::plugin { 'pmd': }
	jenkins::plugin { 'postbuildscript': }
	jenkins::plugin { 'sonar': }
	jenkins::plugin { 'maven-plugin': }
	jenkins::plugin { 'm2release': }
	jenkins::plugin { 'maven-repo-cleaner': }
	jenkins::plugin { 'appdynamics-dashboard': }	
	jenkins::plugin { 'artifactdeployer': }
	jenkins::plugin { 'bitbucket-approve': }
	jenkins::plugin { 'bitbucket-oauth': }
	jenkins::plugin { 'bitbucket-pullrequest-builder': }
	jenkins::plugin { 'build-environment': }
	jenkins::plugin { 'build-failure-analyzer': }
	jenkins::plugin { 'build-monitor-plugin': }
	jenkins::plugin { 'build-with-parameters': }
	jenkins::plugin { 'deployment-notification': }
	jenkins::plugin { 'publish-over-ssh': }
	jenkins::plugin { 'release': }
	jenkins::plugin { 'rapiddeploy-jenkins': }
	jenkins::plugin { 'schedule-build': }
	jenkins::plugin { 'selenium-builder': }
	jenkins::plugin { 'selenium': }
	jenkins::plugin { 'seleniumrc-plugin': }
	jenkins::plugin { 'subversion': }
	jenkins::plugin { 'ssh-agent': }
	jenkins::plugin { 'ssh': }
	jenkins::plugin { 'copyartifact': }
	jenkins::plugin { 'parameterized-trigger': }
	jenkins::plugin { 'delivery-pipeline-plugin': }
	jenkins::plugin { 'create-fingerprint': }
	jenkins::plugin { 'matrix-reloaded': }
	jenkins::plugin { 'jenkins-multijob-plugin': }
	jenkins::plugin { 'join': }
	jenkins::plugin { 'build-flow-plugin': }
	jenkins::plugin { 'promoted-builds': }
	jenkins::plugin { 'scripttrigger': }
	jenkins::plugin { 'build-pipeline-plugin': }
	jenkins::plugin { 'deploy': }
	jenkins::plugin { 'config-file-provider': }
	jenkins::plugin { 'deployer-framework': }
	jenkins::plugin { 'ec2-deployment-dashboard': }
	
	#Jenkins job builder
	class { 'jenkins_job_builder':
		version => 'latest',
	}
}





