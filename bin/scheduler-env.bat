set SCRIPT=%0

rem determine scheduler home; to do this, we strip from the path until we
rem find bin, and then strip bin (there is an assumption here that there is no
rem nested directory under bin also named bin)
for %%I in (%SCRIPT%) do set QTZ_HOME=%%~dpI

:qtz_home_loop
for %%I in ("%QTZ_HOME:~1,-1%") do set DIRNAME=%%~nxI
if not "%DIRNAME%" == "bin" (
  for %%I in ("%QTZ_HOME%..") do set QTZ_HOME=%%~dpfI
  goto qtz_home_loop
)
for %%I in ("%QTZ_HOME%..") do set QTZ_HOME=%%~dpfI

rem now set the classpath
set QTZ_CLASSPATH=!QTZ_HOME!\lib\*;!QTZ_HOME!\conf

rem now set the path to java
if defined JAVA_HOME (
  set JAVA="%JAVA_HOME%\bin\java.exe"
) else (
  for %%I in (java.exe) do set JAVA="%%~$PATH:I"
)

if not exist %JAVA% (
  echo could not find java; set JAVA_HOME or ensure java is in PATH 1>&2
  exit /b 1
)

rem do not let JAVA_TOOL_OPTIONS slip in (as the JVM does by default)
if defined JAVA_TOOL_OPTIONS (
  echo warning: ignoring JAVA_TOOL_OPTIONS=%JAVA_TOOL_OPTIONS%
  set JAVA_TOOL_OPTIONS=
)

rem JAVA_OPTS is not a built-in JVM mechanism but some people think it is so we
rem warn them that we are not observing the value of %JAVA_OPTS%
if defined JAVA_OPTS (
  (echo|set /p=warning: ignoring JAVA_OPTS=%JAVA_OPTS%; )
  echo pass JVM parameters via QTZ_JAVA_OPTS
)

rem check the Java version
%JAVA% -cp "%QTZ_CLASSPATH%" "org.elasticsearch.tools.java_version_checker.JavaVersionChecker" || exit /b 1

set HOSTNAME=%COMPUTERNAME%

if not defined QTZ_PATH_CONF (
  set QTZ_PATH_CONF=!QTZ_HOME!\conf
)

rem now make QTZ_PATH_CONF absolute
for %%I in ("%QTZ_PATH_CONF%..") do set QTZ_PATH_CONF=%%~dpfI

set QTZ_DISTRIBUTION_FLAVOR=default
set QTZ_DISTRIBUTION_TYPE=zip

