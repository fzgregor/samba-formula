{% from "samba/map.jinja" import samba with context %}

smbclient:
  pkg:
    - installed
    - name: {{ samba.smbclient_pkg }}

# create users for samba access and set SAM password
{% for user, data in pillar.get('samba', {}).get("users", {}).items() %}
{{user}}:
  {% if (data.get("delete", false)) %}
    # delete unix user
    user:
      - absent
      - require:
        - cmd: {{user}}
    # remove user from SAM database
    cmd.run:
      - name: pdbedit -x {{user}}
      - onlyif: pdbedit -u {{user}}
      - user: root
      - group: root
      - require:
        - pkg: samba {# pdbedit cmd #}

  {% else %}
    # create unix user
    user.present:
      {% if data.get("uid") %}
      - uid: {{ data.get("uid") }}
      {% endif %}
      - home: /dev/null
      - createhome: false
      - shell: /usr/bin/nologin
      - watch:
        - pkg: samba
        - service: samba
        {% for group in data.get("groups", []) %}
        - group: {{group}}
        {% endfor %}
      # add more groups if needed
      {% if data.get("groups", false) %}
      - groups:
      {% for group in data.get("groups", []) %}
        - {{group}}
      {% endfor %}
      {% endif %}

    # add user to SAM database aka set password
    {% set smbpass = data["smbpass"] %} {# if this fails there is no password in the pillar! #}
    cmd.run:
      - name: printf "$smbpass\n$smbpass\n" | pdbedit -t -a {{user}}
      - unless: pdbedit -u {{user}} && test -n '$smbpass' && smbclient -L localhost -U {{user}}%"$smbpass"
      - env:
        - 'smbpass': '{{smbpass}}'
      {% if (not grains['host'].endswith("test")) %}
      - output_loglevel: quiet
      {% endif %}
      - user: root
      - group: root
      - require:
        - pkg: smbclient {# for unless statement #}
        - pkg: samba     {# pbedit cmd #}
        - user: {{user}}

  {% endif %}
{% endfor %}

# add or remove groups for multi user shares
{% for key, value in pillar.get("samba", {}).get("groups", {}).items() %}
{{key}}:
  group.{{value}}
{% endfor %}
