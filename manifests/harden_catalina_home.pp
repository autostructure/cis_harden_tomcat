# Hardens a catalina home
define cis_harden_tomcat::harden_catalina_home(
  Stdlib::Absolutepath $catalina_home,
  String $owner = 'tomcat_admin',
  String $group = 'tomcat',
  String $checked_os_users = 'root',
  String $minimum_umask = '0007',
) {
  # 2.5 Disable client facing Stack Traces
  augeas { 'Disable client facing Stack Traces':
    incl    => "${catalina_home}/conf/web.xml",
    lens    => 'Xml.lns',
    context => "/files/${catalina_home}/conf/web.xml/web-app",
    changes => [
      'set error-page[last()+1]/exception-type/#text java.lang.Throwable',
      'set error-page[last()]/location/#text /error.jsp',
    ],
    onlyif  => "match error-page[*]/exception-type/#text[.='java.lang.Throwable'] size == 0",
  }

  # 2.6 Turn off TRACE
  augeas { 'Turn off TRACE':
    incl    => "${catalina_home}/conf/server.xml",
    lens    => 'Xml.lns',
    context => "/files/${catalina_home}/conf/server.xml/Server",
    changes => [
      'setm Service[*]/Connector[*]/#attribute allowTrace false',
    ],
  }

  # 3.1 Set a nondeterministic Shutdown command value
  # 4.1 Restrict access to $CATALINA_HOME
  unless defined(File['$catalina_home']) {
    file { $catalina_home:
      ensure => directory,
      mode   => 'g-w,o-rwx',
      owner  => $owner,
      group  => $group,
    }
  }

  # 4.3 Restrict access to Tomcat configuration directory
  file { "${catalina_home}/conf":
    ensure => directory,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.4 Restrict access to Tomcat logs directory
  file { "${catalina_home}/logs":
    ensure => directory,
    mode   => 'o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.5 Restrict access to Tomcat temp directory
  file { "${catalina_home}/temp":
    ensure => directory,
    mode   => 'o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.6 Restrict access to Tomcat binaries directory
  file { "${catalina_home}/bin":
    ensure => directory,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.7 Restrict access to Tomcat web application directory
  file { "${catalina_home}/webapps":
    ensure => directory,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.8 Restrict access to Tomcat web application directory
  file { "${catalina_home}/conf/catalina.policy":
    ensure => file,
    mode   => '0770',
    owner  => $owner,
    group  => $group,
  }

  # 4.9 Restrict access to Tomcat catalina.properties
  file { "${catalina_home}/conf/catalina.properties":
    ensure => file,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.10 Restrict access to Tomcat context.xml
  file { "${catalina_home}/conf/context.xml":
    ensure => file,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.11 Restrict access to Tomcat logging.properties
  file { "${catalina_home}/conf/logging.properties":
    ensure => file,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.12 Restrict access to Tomcat server.xml
  file { "${catalina_home}/conf/server.xml":
    ensure => file,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.13 Restrict access to Tomcat tomcat-users.xml
  file { "${catalina_home}/conf/tomcat-users.xml":
    ensure => file,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 4.14 Restrict access to Tomcat web.xml
  file { "${catalina_home}/conf/web.xml":
    ensure => file,
    mode   => 'g-w,o-rwx',
    owner  => $owner,
    group  => $group,
  }

  # 9.1 Starting Tomcat with Security Manager


  # 10.1 Ensure Web content directory is on a separate partition from the Tomcat system files
  # 10.4 Force SSL when accessing the manager application

  # 10.6 Enable strict servlet Compliance
  $strict_servlet_compliance = '-Dorg.apache.catalina.STRICT_SERVLET_COMPLIANCE=true'

  # 10.7 Turn off session facade recycling
  $recycle_facades = '-Dorg.apache.catalina.connector.RECYCLE_FACADES=true'

  file_line { "${catalina_home}-strict_servlet_compliance":
    ensure => present,
    path   => "${catalina_home}/bin/catalina.sh",
    line   => "JAVA_OPTS=\"\$JAVA_OPTS ${strict_servlet_compliance} ${recycle_facades}\"",
    after  => '^# ----- Execute.+',
  }

  # 10.18 Enable memory leak listener
  ::tomcat::config::server::listener {"${catalina_home}-org.apache.catalina.core.JreMemoryLeakPreventionListener":
    class_name      => 'org.apache.catalina.core.JreMemoryLeakPreventionListener',
    catalina_base   => $catalina_home,
    listener_ensure => present,
  }

  # 10.19 Setting Security Lifecycle Listener
  file_line { "${catalina_home}-SecurityListener_umask":
    ensure => present,
    path   => "${catalina_home}/bin/catalina.sh",
    line   => 'JAVA_OPTS="$JAVA_OPTS -Dorg.apache.catalina.security.SecurityListener.UMASK=`umask`"',
    match  => '^#JAVA_OPTS="\$JAVA_OPTS -Dorg.apache.catalina.security.SecurityListener.UMASK=`umask`"',
  }

  ::tomcat::config::server::listener {"${catalina_home}-org.apache.catalina.security.SecurityListener":
    class_name            => 'org.apache.catalina.security.SecurityListener',
    catalina_base         => $catalina_home,
    listener_ensure       => present,
    additional_attributes => {
      checkedOsUsers => $checked_os_users,
      minimumUmask   => $minimum_umask,
    },
  }

}
