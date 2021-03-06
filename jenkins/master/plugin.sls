{%- from "jenkins/map.jinja" import master with context %}

{{ master.home }}/updates:
  file.directory:
  - user: jenkins
  - group: {{ master.nogroup }}

setup_jenkins_cli:
  cmd.run:
  - names:
    - wget http://localhost:{{ master.http.port }}/jnlpJars/jenkins-cli.jar
  - unless: "[ -f /root/jenkins-cli.jar ]"
  - cwd: /root
  - require:
    - cmd: jenkins_service_running

{%- if master.plugins is defined %}
{%- set master_username = master.admin_user | default('admin') %}
{%- for plugin in master.plugins %}

install_jenkins_plugin_{{ plugin.name }}:
  cmd.run:
  - name: >
      java -jar jenkins-cli.jar -s http://localhost:{{ master.http.port }} install-plugin --username {{ master_username }} --password '{{ master.admin_pwd }}' {{ plugin.name }}
  - unless: "[ -d {{ master.home }}/plugins/{{ plugin.name }} ]"
  - cwd: /root
  - require:
    - cmd: setup_jenkins_cli
    - cmd: jenkins_service_running

{%- endfor %}
{%- endif %}
