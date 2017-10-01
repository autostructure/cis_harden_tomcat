# Hardens a catalina home
define cis_harden_tomcat::harden_application(
  Stdlib::Absolutepath $catalina_home,
  Stdlib::Absolutepath $catalina_base,
  String $application,
  String $owner = 'tomcat_admin',
  String $group = 'tomcat',
) {
  # 4.2 Restrict access to $CATALINA_BASE
  unless defined(File['$catalina_base']) {
    file { $catalina_base:
      ensure => directory,
      mode   => 'g-w,o-rwx',
      owner  => $owner,
      group  => $group,
    }
  }

  # 7.2 Specify file handler in logging.properties files
  file_line { "${name}_logging_handler":
    ensure => present,
    path   => "${catalina_base}/webapps/${application}/WEB-INF/classes/logging.properties",
    line   => 'handlers=org.apache.juli.FileHandler, java.util.logging.ConsoleHandler',
    match  => '^handlers=',
  }

  file_line { "${name}_logging_level":
    ensure  => present,
    path    => "${catalina_base}/webapps/${application}/WEB-INF/classes/logging.properties",
    line    => 'org.apache.juli.FileHandler.level=INFO',
    match   => '^org.apache.juli.FileHandler.level=',
    replace => false,
  }

  # 7.4 Ensure directory in context.xml is a secure location
  # 7.5 Ensure pattern in context.xml is correct
  augeas { "${name}_context_loggin":
    incl    => "${catalina_base}/webapps/${application}/META-INF/context.xml",
    lens    => 'Xml.lns',
    context => "/files/${catalina_base}/webapps/${application}/META-INF/context.xml/",
    changes => [
      'set /files/tmp/Context/Valve/#attribute/directory $CATALINA_HOME/logs/',
      'set /files/tmp/Context/Valve/#attribute/prefix access_log',
      'set /files/tmp/Context/Valve/#attribute/fileDateFormat yyyy-MM-dd.HH',
      'set /files/tmp/Context/Valve/#attribute/suffix .log',
      'set /files/tmp/Context/Valve/#attribute/pattern \'%h %t %H cookie:%{SESSIONID}c request:%{SESSIONID}r %m %U %s %q %r\'',
    ],
  }

  # Set the logEffectiveWebXml value in the context.xml in each of applications to true
  # 10.14 Do not allow symbolic linking (Scored)
  # 10.15 Do not run applications as privileged (Scored)
  # 10.16 Do not allow cross context requests (Scored)
  # 10.20 use the logEffectiveWebXml and metadata-complete settings for deploying applications in production
  augeas { "${name}_logEffectiveWebXml_true":
    incl    => "${catalina_base}/webapps/${application}/META-INF/context.xml",
    lens    => 'Xml.lns',
    context => "/files/${catalina_base}/webapps/${application}/META-INF/context.xml/",
    changes => [
      'set Context/#attribute/logEffectiveWebXml true',
      'set Context/#attribute/crossContext false',
      'set Context/#attribute/privileged false',
      'set Context/#attribute/allowLinking false',
    ],
  }
}
