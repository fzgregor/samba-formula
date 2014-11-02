{% from "samba/map.jinja" import samba with context %}

samba:
  pkg:
    - installed

  service:
    - running
    - name: {{ samba.service }}
    - reload: True
    - enable: True
    - watch:
      - pkg: samba
      - file: /etc/samba/smb.conf

/etc/samba/smb.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - contents: |
      {% set smb_conf = pillar.get("samba", {'smb_conf':{}})["smb_conf"] %}
      {% for section, options in smb_conf.items() %}
        [{{section}}]
        {% for name, value in options.items() %}
          {{name}} = {{value}}
        {% endfor %}
      {% endfor %}
